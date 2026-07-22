# frozen_string_literal: true

module Catalog
  class CatalogWorkbookBuilder
    def self.call(records)
      new(records).call
    end

    def initialize(records)
      @records = records
    end

    def call
      SheetHeaders::SHEET_ORDER.map do |sheet_name, headers|
        { name: sheet_name, headers: headers, rows: rows_for(sheet_name) }
      end
    end

    private

    def rows_for(sheet_name)
      case sheet_name
      when "Origen" then origen_rows
      when "Aplicaciones" then aplicaciones_rows
      when "Intercambios" then intercambios_rows
      when "Catálogo" then catalogo_rows
      else
        raise ArgumentError, "Unknown sheet #{sheet_name}"
      end
    end

    def origen_rows
      @records.map do |record|
        [
          record.reference,
          record.brand,
          record.part_number,
          record.description
        ]
      end
    end

    def aplicaciones_rows
      @records.map do |record|
        [
          record.reference,
          record.brand,
          record.description,
          nil,
          nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
        ]
      end
    end

    def intercambios_rows
      @records.map do |record|
        [
          record.reference,
          record.brand,
          record.description,
          record.part_number,
          record.brand,
          record.brand
        ]
      end
    end

    def catalogo_rows
      @records.map do |record|
        taxonomy = TaxonomyGuess.call(record.description)
        [
          record.reference,
          record.brand,
          taxonomy[:categoria],
          taxonomy[:sistema],
          taxonomy[:subsistema],
          record.description,
          record.description
        ]
      end
    end
  end
end
