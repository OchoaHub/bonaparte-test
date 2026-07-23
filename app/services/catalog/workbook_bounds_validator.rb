# frozen_string_literal: true

require "zip"
require "nokogiri"

module Catalog
  class WorkbookBoundsValidator
    MAX_UNCOMPRESSED_BYTES = 50.megabytes
    MAX_WORKSHEETS = 32
    MAX_ORIGEN_ROWS = 5_000
    OVERSIZE_ALERT = "El archivo Excel supera los límites permitidos (tamaño descomprimido, hojas o filas)."
    SPREADSHEET_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"

    class LimitExceeded < StandardError; end

    def self.call!(path:)
      new(path).call!
    end

    def initialize(path)
      @path = path
    end

    def call!
      Zip::File.open(@path) do |zip|
        validate_uncompressed_size!(zip)
        validate_worksheet_count!(zip)
        validate_origen_row_count!(zip)
      end
    end

    private

    def validate_uncompressed_size!(zip)
      total = zip.entries.sum(&:size)
      return if total <= MAX_UNCOMPRESSED_BYTES

      raise LimitExceeded, OVERSIZE_ALERT
    end

    def validate_worksheet_count!(zip)
      workbook = read_zip_entry(zip, "xl/workbook.xml")
      sheet_count = Nokogiri::XML(workbook).xpath("//main:sheet", "main" => SPREADSHEET_NS).size
      return if sheet_count.positive? && sheet_count <= MAX_WORKSHEETS

      raise LimitExceeded, OVERSIZE_ALERT
    end

    def validate_origen_row_count!(zip)
      sheet_path = origen_worksheet_path(zip)
      return unless sheet_path

      sheet_xml = read_zip_entry(zip, sheet_path)
      row_count = Nokogiri::XML(sheet_xml).xpath("//main:row", "main" => SPREADSHEET_NS).size
      return if row_count <= MAX_ORIGEN_ROWS

      raise LimitExceeded, OVERSIZE_ALERT
    end

    def origen_worksheet_path(zip)
      workbook = read_zip_entry(zip, "xl/workbook.xml")
      rels = read_zip_entry(zip, "xl/_rels/workbook.xml.rels")
      doc = Nokogiri::XML(workbook)
      sheet_node = doc.at_xpath("//main:sheet[@name='Origen']", "main" => SPREADSHEET_NS)
      return unless sheet_node

      relationship_id = sheet_node["r:id"]
      rels_doc = Nokogiri::XML(rels)
      rel = rels_doc.at_xpath("//rel:Relationship[@Id='#{relationship_id}']", "rel" => "http://schemas.openxmlformats.org/package/2006/relationships")
      target = rel&.[]("Target")
      return unless target

      target = target.delete_prefix("/")
      target.start_with?("xl/") ? target : "xl/#{target}"
    end

    def read_zip_entry(zip, name)
      entry = zip.find_entry(name)
      raise LimitExceeded, "No se pudo leer el archivo Excel." unless entry

      entry.get_input_stream.read
    end
  end
end
