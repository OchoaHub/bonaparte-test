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
    assert_origen_cells_stored_as_text(output)
    assert_no_blank_data_rows(origen, "Origen")
    assert_no_blank_data_rows(workbook.sheet(workbook.sheets.last), "Catálogo")
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

  def assert_no_blank_data_rows(sheet, sheet_name)
    (2..sheet.last_row).each do |row_number|
      row = sheet.row(row_number).map { |cell| cell.to_s.strip }
      refute row.all?(&:empty?), "expected no blank rows, found empty row #{row_number} in #{sheet_name}"
    end
  end

  def assert_origen_cells_stored_as_text(path)
    sheet_xml = Zip::File.open(path).read("xl/worksheets/sheet1.xml")
    doc = Nokogiri::XML(sheet_xml)
    ns = { "m" => "http://schemas.openxmlformats.org/spreadsheetml/2006/main" }

    doc.xpath("//m:sheetData/m:row[position()>1]/m:c[starts-with(@r, 'A') or starts-with(@r, 'C')]", ns).each do |cell|
      assert_not_equal "n", cell["t"], "expected text cells for SKU and part number, got numeric #{cell['r']}"
    end
  end
end
