# frozen_string_literal: true

require "zip"
require "nokogiri"
require "stringio"

module Catalog
  class WorkbookCompactor
    SPREADSHEET_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
    TARGET_SHEETS = ["Origen", "Catálogo"].freeze

    def self.call(xlsx_bytes)
      new(xlsx_bytes).call
    end

    def initialize(xlsx_bytes)
      @xlsx_bytes = xlsx_bytes
    end

    def call
      buffer = StringIO.new
      buffer.binmode

      Zip::OutputStream.write_buffer(buffer) do |out|
        Zip::File.open_buffer(@xlsx_bytes) do |zip|
          targets = target_sheet_paths(zip)

          zip.each do |entry|
            next if entry.name.start_with?("xl/tables/")

            data = entry.get_input_stream.read
            data = compact_sheet(data) if targets.value?(entry.name)
            data = strip_table_reference(data) if entry.name.match?(%r{\Axl/worksheets/_rels/sheet\d+\.xml\.rels\z})
            out.put_next_entry(entry.name)
            out.write(data)
          end
        end
      end

      buffer.string
    end

    private

    def target_sheet_paths(zip)
      sheet_map = sheet_paths_by_name(zip)
      sheet_map.slice(*TARGET_SHEETS.filter { |name| sheet_map.key?(name) })
    end

    def sheet_paths_by_name(zip)
      workbook = Nokogiri::XML(read_entry(zip, "xl/workbook.xml"))
      rels = Nokogiri::XML(read_entry(zip, "xl/_rels/workbook.xml.rels"))

      workbook.xpath("//main:sheet", "main" => SPREADSHEET_NS).each_with_object({}) do |node, map|
        name = node["name"]
        relationship_id = node["r:id"]
        rel = rels.at_xpath("//rel:Relationship[@Id='#{relationship_id}']", "rel" => REL_NS)
        target = rel&.[]("Target")
        next unless name && target

        path = target.delete_prefix("/")
        path = "xl/#{path}" unless path.start_with?("xl/")
        map[name] = path
      end
    end

    def compact_sheet(xml_bytes)
      doc = Nokogiri::XML(xml_bytes)
      sheet_data = doc.at_xpath("//main:sheetData", "main" => SPREADSHEET_NS)
      return xml_bytes unless sheet_data

      rows = sheet_data.xpath("main:row", "main" => SPREADSHEET_NS).to_a
      kept_rows = rows.select do |row|
        row["r"].to_i == 1 || row_has_value?(row)
      end

      rows.each { |row| row.remove }
      kept_rows.each { |row| sheet_data.add_child(row) }

      update_dimension!(doc, kept_rows)
      doc.at_xpath("//main:tableParts", "main" => SPREADSHEET_NS)&.remove

      doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    end

    def row_has_value?(row)
      row.xpath("main:c", "main" => SPREADSHEET_NS).any? { |cell| cell_value(cell).present? }
    end

    def cell_value(cell)
      inline = cell.at_xpath("main:is", "main" => SPREADSHEET_NS)
      return inline.text.strip if inline

      value_node = cell.at_xpath("main:v", "main" => SPREADSHEET_NS)
      return "" unless value_node

      value_node.text.to_s.strip
    end

    def update_dimension!(doc, rows)
      return if rows.empty?

      max_row = rows.map { |row| row["r"].to_i }.max
      max_col = rows.flat_map do |row|
        row.xpath("main:c", "main" => SPREADSHEET_NS).filter_map do |cell|
          column_letters(cell["r"])
        end
      end.map { |letters| column_index(letters) }.max || 1

      ref = "A1:#{index_to_column(max_col)}#{max_row}"
      dimension = doc.at_xpath("//main:dimension", "main" => SPREADSHEET_NS)
      if dimension
        dimension["ref"] = ref
      else
        doc.root.prepend_child(%(<dimension ref="#{ref}"/>))
      end
    end

    def column_letters(cell_ref)
      cell_ref.to_s.gsub(/\d+/, "")
    end

    def column_index(letters)
      letters.chars.reduce(0) { |sum, char| (sum * 26) + (char.ord - 64) }
    end

    def index_to_column(index)
      name = +""
      while index.positive?
        index, remainder = (index - 1).divmod(26)
        name.prepend((65 + remainder).chr)
      end
      name
    end

    def strip_table_reference(rels_xml)
      doc = Nokogiri::XML(rels_xml)
      doc.xpath("//rel:Relationship", "rel" => REL_NS).each do |rel|
        rel.remove if rel["Type"]&.include?("/table")
      end
      doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    end

    def read_entry(zip, name)
      entry = zip.find_entry(name)
      raise "Missing #{name} in workbook" unless entry

      entry.get_input_stream.read
    end
  end
end
