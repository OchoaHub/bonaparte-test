# frozen_string_literal: true

require "test_helper"

module Catalog
  class CatalogPipelineTest < ActiveSupport::TestCase
    test "generates workbook with four sheets and five data rows each" do
      input = file_fixture("prueba_tecnica.xlsx").to_s
      output = Rails.root.join("tmp/catalog_pipeline_test_output.xlsx").to_s

      CatalogPipeline.call(input_path: input, output_path: output)

      workbook = Roo::Spreadsheet.open(output)

      assert_equal ["Origen", "Aplicaciones", "Intercambios", "Catálogo"], workbook.sheets

      assert_sheet(workbook, "Origen", SheetHeaders::ORIGEN, 5)
      assert_sheet(workbook, "Aplicaciones", SheetHeaders::APLICACIONES, 5)
      assert_sheet(workbook, "Intercambios", SheetHeaders::INTERCAMBIOS, 5)
      assert_sheet(workbook, "Catálogo", SheetHeaders::CATALOGO, 5)
    ensure
      File.delete(output) if output && File.exist?(output)
    end

    private

    def assert_sheet(workbook, name, expected_headers, expected_rows)
      sheet = workbook.sheet(name)
      headers = sheet.row(1).map { |cell| cell.to_s }

      assert_equal expected_headers, headers
      assert_equal expected_rows + 1, sheet.last_row
    end
  end
end
