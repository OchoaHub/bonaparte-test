# frozen_string_literal: true

require "test_helper"

class ExcelCatalogGeneratorTest < ActiveSupport::TestCase
  APLICACIONES_HEADERS = ExcelCatalogGenerator::APLICACIONES_HEADERS
  INTERCAMBIOS_HEADERS = ExcelCatalogGenerator::INTERCAMBIOS_HEADERS
  CATALOGO_HEADERS = ExcelCatalogGenerator::CATALOGO_HEADERS

  test "generates workbook with four sheets and mock-expanded rows" do
    input = file_fixture("prueba_tecnica.xlsx").to_s
    output = Rails.root.join("tmp/excel_catalog_generator_test.xlsx").to_s

    ExcelCatalogGenerator.new(input).call(output)

    workbook = Roo::Spreadsheet.open(output)

    assert_equal ["Origen", "Aplicaciones", "Intercambios", "Catálogo"], workbook.sheets

    assert_sheet(workbook, "Origen", Catalog::SheetHeaders::ORIGEN, 5)
    assert_sheet(workbook, "Aplicaciones", APLICACIONES_HEADERS, 10)
    assert_sheet(workbook, "Intercambios", INTERCAMBIOS_HEADERS, 16)
    assert_sheet(workbook, "Catálogo", CATALOGO_HEADERS, 5)

    aplicaciones = workbook.sheet("Aplicaciones")
    first_data_row = aplicaciones.row(2)

    assert_equal "96353002-FE", first_data_row[0]
    assert_equal "CHEVROLET", first_data_row[4]
    assert_equal "Chevy", first_data_row[5]
    assert_equal 2008, first_data_row[7]

    origen = workbook.sheet("Origen")
    assert_equal "96353002-FE", origen.row(2)[0]
    assert_equal "Meistersatz", origen.row(2)[1]
    assert_equal "96353002", origen.row(2)[2].to_s
    assert_equal "JUNTA TAPA DE PUNTERIAS", origen.row(2)[3]
  ensure
    File.delete(output) if output && File.exist?(output)
  end

  test "to_stream returns non-empty xlsx bytes" do
    input = file_fixture("prueba_tecnica.xlsx").to_s
    bytes = ExcelCatalogGenerator.new(input).to_stream

    assert bytes.bytesize.positive?
    assert_equal "PK", bytes.byteslice(0, 2)
  end

  private

  def assert_sheet(workbook, name, expected_headers, expected_data_rows)
    sheet = workbook.sheet(name)
    headers = sheet.row(1).map { |cell| cell.to_s }

    assert_equal expected_headers, headers
    assert_equal expected_data_rows + 1, sheet.last_row
  end
end
