# frozen_string_literal: true

module Catalog
  module SheetHeaders
    ORIGEN = [
      "# SKU",
      "Marca",
      "Numero de parte ",
      "Descripción operación"
    ].freeze

    APLICACIONES = [
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

    INTERCAMBIOS = [
      "Referencia",
      "Marca",
      "Producto",
      "Intercambio",
      "Marca",
      "Origen"
    ].freeze

    CATALOGO = [
      "Referencia",
      "Marca",
      "Categoría",
      "Sistema",
      "Subsistema",
      "Producto",
      "Descripción"
    ].freeze

    SHEET_ORDER = [
      ["Origen", ORIGEN],
      ["Aplicaciones", APLICACIONES],
      ["Intercambios", INTERCAMBIOS],
      ["Catálogo", CATALOGO]
    ].freeze
  end
end
