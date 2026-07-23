# frozen_string_literal: true

require "caxlsx"

class ExcelCatalogGenerator
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
    aplicaciones_rows, intercambios_rows, catalogo_rows = build_rows

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
      catalogo_rows.each { |row| sheet.add_row(row) }
    end

    package
  end

  def build_rows
    aplicaciones_rows = []
    intercambios_rows = []
    catalogo_rows = []

    read_skus.each do |sku|
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

    [aplicaciones_rows, intercambios_rows, catalogo_rows]
  end

  def read_skus
    sheet = Roo::Spreadsheet.open(@upload_path).sheet(0)
    last_row = sheet.last_row.to_i
    return [] if last_row < 2

    skus = (2..last_row).filter_map do |row_number|
      sku = sheet.cell(row_number, 1).to_s.strip
      sku.presence
    end

    skus.uniq
  end
end
