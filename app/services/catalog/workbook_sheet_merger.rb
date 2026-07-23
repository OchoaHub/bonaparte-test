# frozen_string_literal: true

require "zip"
require "nokogiri"
require "fileutils"

module Catalog
  class WorkbookSheetMerger
    SPREADSHEET_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
    SHEET_NAMES = ["Origen", "Aplicaciones", "Intercambios", "Catálogo"].freeze

    def self.call(template_path:, data_path:, output_path:)
      new(template_path: template_path, data_path: data_path, output_path: output_path).call
    end

    def initialize(template_path:, data_path:, output_path:)
      @template_path = template_path
      @data_path = data_path
      @output_path = output_path
    end

    def call
      FileUtils.cp(@template_path, @output_path)

      template_sheets = sheet_paths_by_name(@template_path)
      data_sheets = sheet_paths_by_name(@data_path)

      SHEET_NAMES.each do |name|
        template_entry = template_sheets[name]
        data_entry = data_sheets[name]
        next unless template_entry && data_entry

        replace_zip_entry(@output_path, template_entry, read_zip_entry(@data_path, data_entry))
      end

      @output_path
    end

    private

    def sheet_paths_by_name(path)
      Zip::File.open(path) do |zip|
        workbook = Nokogiri::XML(read_entry(zip, "xl/workbook.xml"))
        rels = Nokogiri::XML(read_entry(zip, "xl/_rels/workbook.xml.rels"))

        workbook.xpath("//main:sheet", "main" => SPREADSHEET_NS).each_with_object({}) do |node, map|
          name = node["name"]
          relationship_id = node["r:id"]
          rel = rels.at_xpath("//rel:Relationship[@Id='#{relationship_id}']", "rel" => REL_NS)
          target = rel&.[]("Target")
          next unless name && target

          entry = target.delete_prefix("/")
          entry = "xl/#{entry}" unless entry.start_with?("xl/")
          map[name] = entry
        end
      end
    end

    def replace_zip_entry(path, entry_name, new_data)
      temp_path = "#{path}.merging"
      File.open(temp_path, "wb") do |file|
        Zip::OutputStream.open(file) do |out|
          Zip::File.open(path) do |zip|
            zip.each do |entry|
              data = entry.name == entry_name ? new_data : entry.get_input_stream.read
              out.put_next_entry(entry.name)
              out.write(data)
            end
          end
        end
      end

      FileUtils.mv(temp_path, path)
    end

    def read_zip_entry(path, entry_name)
      Zip::File.open(path) { |zip| read_entry(zip, entry_name) }
    end

    def read_entry(zip, name)
      entry = zip.find_entry(name)
      raise "Missing #{name} in workbook" unless entry

      entry.get_input_stream.read
    end
  end
end
