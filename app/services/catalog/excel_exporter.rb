# frozen_string_literal: true

require "caxlsx"

module Catalog
  class ExcelExporter
    def self.call(sheets, output_path)
      new(sheets, output_path).call
    end

    def initialize(sheets, output_path)
      @sheets = sheets
      @output_path = output_path
    end

    def call
      package = Axlsx::Package.new
      workbook = package.workbook

      @sheets.each do |sheet|
        workbook.add_worksheet(name: sheet[:name]) do |worksheet|
          worksheet.add_row(sheet[:headers])
          sheet[:rows].each { |row| worksheet.add_row(row) }
        end
      end

      package.serialize(@output_path)
      @output_path
    end
  end
end
