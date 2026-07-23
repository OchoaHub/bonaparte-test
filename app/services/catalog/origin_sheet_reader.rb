# frozen_string_literal: true

module Catalog
  class OriginSheetReader
    SHEET_NAME = "Origen"

    def self.call(path)
      new(path).call
    end

    def initialize(path)
      @path = path
    end

    def call
      sheet = Roo::Spreadsheet.open(@path).sheet(SHEET_NAME)
      enforce_row_bounds!(sheet)

      header_row = sheet.row(1).map { |cell| cell.to_s.strip }
      indices = column_indices(header_row)

      last_row = [sheet.last_row.to_i, WorkbookBoundsValidator::MAX_ORIGEN_ROWS].min
      (2..last_row).filter_map do |row_number|
        row = sheet.row(row_number)
        sku = cell_value(row, indices[:sku])
        next if sku.blank?

        PartExtractor.call(
          sku: sku,
          description: cell_value(row, indices[:description]),
          brand: cell_value(row, indices[:brand])
        )
      end
    end

    private

    def column_indices(header_row)
      {
        sku: find_column(header_row, "sku"),
        description: find_column(header_row, "description"),
        brand: find_column(header_row, "brand")
      }
    end

    def find_column(header_row, name)
      index = header_row.find_index { |header| header.casecmp?(name) }
      raise ArgumentError, "Missing column #{name} in Origen sheet" unless index

      index
    end

    def cell_value(row, index)
      value = row[index]
      value.nil? ? "" : value.to_s.strip
    end

    def enforce_row_bounds!(sheet)
      return if sheet.last_row.to_i <= WorkbookBoundsValidator::MAX_ORIGEN_ROWS

      raise WorkbookBoundsValidator::LimitExceeded, WorkbookBoundsValidator::OVERSIZE_ALERT
    end
  end
end
