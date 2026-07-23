# frozen_string_literal: true

require "caxlsx"

class ExcelCatalogGenerator
  ORIGEN_HEADERS = Catalog::SheetHeaders::ORIGEN

  APLICACIONES_HEADERS = [
    "Referencia",
    "Marca",
    "Producto",
    "Posición",
    "Fabricante",
    "Modelo",
    "Submodelo",
    "Año",
    "Litros",
    "CC",
    "CID",
    "Cilindros",
    "Bloque",
    "Combustible",
    "Mercado"
  ].freeze

  INTERCAMBIOS_HEADERS = [
    "Referencia",
    "Marca",
    "Producto",
    "Intercambio",
    "MarcaOrigen",
    "Origen"
  ].freeze

  CATALOGO_HEADERS = [
    "Referencia",
    "Marca",
    "Categoría",
    "Sistema",
    "Subsistema",
    "Producto",
    "Descripción"
  ].freeze

  def initialize(upload_path)
    @upload_path = upload_path
  end

  def call(output_path = nil)
    output_path ||= default_output_path
    package.serialize(output_path)
    output_path
  end

  def to_stream
    package.to_stream.read
  end

  private

  def default_output_path
    Rails.root.join("tmp", "catalogo_#{SecureRandom.hex(8)}.xlsx").to_s
  end

  def package
    @package ||= build_package
  end

  def build_package
    package = Axlsx::Package.new
    workbook = package.workbook
    origen_rows, aplicaciones_rows, intercambios_rows, catalogo_rows = build_rows

    workbook.add_worksheet(name: "Origen") do |sheet|
      sheet.add_row(ORIGEN_HEADERS)
      add_compact_rows(sheet, origen_rows)
    end

    workbook.add_worksheet(name: "Aplicaciones") do |sheet|
      sheet.add_row(APLICACIONES_HEADERS)
      aplicaciones_rows.each { |row| sheet.add_row(row) }
    end

    workbook.add_worksheet(name: "Intercambios") do |sheet|
      sheet.add_row(INTERCAMBIOS_HEADERS)
      intercambios_rows.each { |row| sheet.add_row(row) }
    end

    workbook.add_worksheet(name: "Catálogo") do |sheet|
      sheet.add_row(CATALOGO_HEADERS)
      add_compact_rows(sheet, catalogo_rows)
    end

    package
  end

  def build_rows
    origen_rows = []
    aplicaciones_rows = []
    intercambios_rows = []
    catalogo_rows = []

    entries = read_origin_entries
    entries.each do |entry|
      record = Catalog::PartExtractor.call(
        sku: entry[:sku],
        description: entry[:description],
        brand: entry[:brand]
      )
      origen_rows << [
        record.reference,
        record.brand,
        record.part_number,
        record.description
      ]
    end

    seen_skus = {}
    entries.each do |entry|
      sku = entry[:sku]
      next if seen_skus[sku]

      seen_skus[sku] = true
      data = AutopartsMockService.lookup(sku)
      referencia = data[:referencia]
      marca = data[:marca]
      producto = data[:producto]
      catalogo = data[:catalogo]

      data[:aplicaciones].each do |app|
        aplicaciones_rows << [
          referencia,
          marca,
          producto,
          app[:Posicion],
          app[:Fabricante],
          app[:Modelo],
          app[:Submodelo],
          app[:Ano],
          app[:Litros],
          app[:CC],
          app[:CID],
          app[:Cilindros],
          app[:Bloque],
          app[:Combustible],
          app[:Mercado]
        ]
      end

      data[:intercambios].each do |ix|
        intercambios_rows << [
          referencia,
          marca,
          producto,
          ix[:Intercambio],
          ix[:MarcaOrigen],
          ix[:Origen]
        ]
      end

      catalogo_rows << [
        referencia,
        marca,
        catalogo[:Categoria],
        catalogo[:Sistema],
        catalogo[:Subsistema],
        producto,
        catalogo[:Descripcion]
      ]
    end

    [origen_rows, aplicaciones_rows, intercambios_rows, catalogo_rows]
  end

  def read_origin_entries
    sheet = origin_sheet
    max_row = Catalog::WorkbookBoundsValidator::MAX_ORIGEN_ROWS
    header_row = sheet.row(1).map { |cell| cell.to_s.strip }
    indices = origin_column_indices(header_row)
    last_row = last_origin_data_row(sheet, indices, max_row)
    return [] if last_row < 2

    (2..last_row).filter_map do |row_number|
      row = sheet.row(row_number)
      sku = normalize_sku(origin_cell_value(row, indices[:sku]))
      next unless sku

      {
        sku: sku,
        description: origin_cell_value(row, indices[:description]),
        brand: origin_cell_value(row, indices[:brand])
      }
    end
  end

  def origin_sheet
    @origin_sheet ||= begin
      book = Roo::Spreadsheet.open(@upload_path)
      if book.sheets.any? { |name| name.casecmp?("origen") }
        book.sheet("Origen")
      else
        book.sheet(0)
      end
    end
  end

  def origin_column_indices(header_row)
    sku_index = find_origin_column(header_row, "sku") ||
                find_origin_column(header_row, "referencia") ||
                0
    description_index = find_origin_column(header_row, "description") ||
                        find_origin_column(header_row, "descripción operación") ||
                        find_origin_column(header_row, "descripcion operacion") ||
                        1
    brand_index = find_origin_column(header_row, "brand") ||
                  find_origin_column(header_row, "marca") ||
                  2

    { sku: sku_index, description: description_index, brand: brand_index }
  end

  def find_origin_column(header_row, name)
    header_row.find_index do |header|
      normalize_header(header) == normalize_header(name)
    end
  end

  def normalize_header(header)
    ActiveSupport::Inflector.transliterate(header.to_s.strip.downcase.delete("#")).squeeze(" ").strip
  end

  def last_origin_data_row(sheet, indices, max_row)
    upper = [sheet.last_row.to_i, max_row].min
    upper.downto(2) do |row_number|
      row = sheet.row(row_number)
      return row_number if normalize_sku(origin_cell_value(row, indices[:sku]))
    end
    1
  end

  def add_compact_rows(sheet, rows)
    rows.each do |row|
      next if row_blank?(row)

      sheet.add_row(row)
    end
  end

  def row_blank?(row)
    row.all? { |cell| cell.nil? || cell.to_s.strip.empty? }
  end

  def origin_cell_value(row, index)
    value = row[index]
    value.nil? ? "" : value.to_s.strip
  end

  def normalize_sku(value)
    return if value.nil?

    sku = if value.is_a?(Float) && value == value.truncate
            value.truncate.to_s
          elsif value.is_a?(Integer)
            value.to_s
          else
            value.to_s.strip
          end
    sku.presence
  end
end
