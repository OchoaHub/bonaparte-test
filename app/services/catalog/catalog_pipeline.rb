# frozen_string_literal: true

module Catalog
  class CatalogPipeline
    def self.call(input_path:, output_path:)
      records = OriginSheetReader.call(input_path)
      sheets = CatalogWorkbookBuilder.call(records)
      ExcelExporter.call(sheets, output_path)
    end
  end
end
