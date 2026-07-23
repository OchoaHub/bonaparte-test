# frozen_string_literal: true

module Catalog
  class TaxonomyGuess
    DEFAULT = {
      categoria: "Vehiculo ligero",
      sistema: "GENERAL",
      subsistema: "Sin clasificar"
    }.freeze

    RULES = [
      {
        pattern: /MANGUERA/i,
        categoria: "Vehiculo ligero",
        sistema: "BANDAS Y ENFRIAMIENTO",
        subsistema: "MANGUERAS Y TUBERÍAS"
      },
      {
        pattern: /HORQUILLA/i,
        categoria: "Vehiculo ligero",
        sistema: "SUSPENSIÓN",
        subsistema: "BRAZOS Y HORQUILLAS"
      },
      {
        pattern: /JUNTA/i,
        categoria: "Vehiculo ligero",
        sistema: "MOTOR",
        subsistema: "JUNTAS Y EMPAQUES"
      },
      {
        pattern: /DEPOSITO|FLUIDO/i,
        categoria: "Vehiculo ligero",
        sistema: "DIRECCIÓN",
        subsistema: "COMPONENTES DE DIRECCIÓN ASISTIDA"
      }
    ].freeze

    def self.call(description)
      text = description.to_s
      rule = RULES.find { |entry| text.match?(entry[:pattern]) }
      return DEFAULT.dup unless rule

      {
        categoria: rule[:categoria],
        sistema: rule[:sistema],
        subsistema: rule[:subsistema]
      }
    end
  end
end
