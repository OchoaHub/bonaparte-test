# frozen_string_literal: true

module Catalog
  class CatalogPipeline
    MAX_RECORDS = 5_000

    def self.call(input_path:, output_path:)
      WorkbookBoundsValidator.call!(path: input_path)
      records = OriginSheetReader.call(input_path)
      if records.size > MAX_RECORDS
        raise WorkbookBoundsValidator::LimitExceeded, WorkbookBoundsValidator::OVERSIZE_ALERT
      end

      sheets = CatalogWorkbookBuilder.call(records)
      ExcelExporter.call(sheets, output_path)
    end
  end
end
