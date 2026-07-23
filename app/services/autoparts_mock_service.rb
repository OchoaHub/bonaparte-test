# frozen_string_literal: true

class AutopartsMockService
  MOCK_DATA = {
    "96353002-FE" => {
      referencia: "96353002-FE",
      marca: "Meistersatz",
      producto: "JUNTA TAPA DE PUNTERIAS",
      aplicaciones: [
        {
          Posicion: "Motor",
          Fabricante: "CHEVROLET",
          Modelo: "Chevy",
          Submodelo: "C2",
          Ano: 2008,
          Litros: "1.6",
          CC: "1598",
          CID: "98",
          Cilindros: "4",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "MEX"
        },
        {
          Posicion: "Motor",
          Fabricante: "CHEVROLET",
          Modelo: "Aveo",
          Submodelo: "LS",
          Ano: 2012,
          Litros: "1.6",
          CC: "1598",
          CID: "98",
          Cilindros: "4",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "MEX"
        }
      ],
      intercambios: [
        { Intercambio: "96353002", MarcaOrigen: "GM", Origen: "OEM" },
        { Intercambio: "VS50504R", MarcaOrigen: "Fel-Pro", Origen: "Aftermarket" },
        { Intercambio: "15-53472-01", MarcaOrigen: "Victor Reinz", Origen: "Aftermarket" }
      ],
      catalogo: {
        Categoria: "Vehiculo ligero",
        Sistema: "MOTOR",
        Subsistema: "JUNTAS Y RETENES",
        Descripcion: "Junta de tapa de punterías (sellos de válvulas), diseñada para evitar fugas de aceite en la parte superior del motor."
      }
    },

    "32416851217-FE" => {
      referencia: "32416851217-FE",
      marca: "Meistersatz",
      producto: "DEPOSITO FLUIDO DIR HIDRAULICA",
      aplicaciones: [
        {
          Posicion: "Dirección",
          Fabricante: "BMW",
          Modelo: "Serie 3",
          Submodelo: "325i",
          Ano: 2006,
          Litros: "2.5",
          CC: "2494",
          CID: "152",
          Cilindros: "6",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "US/MEX"
        },
        {
          Posicion: "Dirección",
          Fabricante: "BMW",
          Modelo: "Serie 5",
          Submodelo: "530i",
          Ano: 2004,
          Litros: "3.0",
          CC: "2979",
          CID: "182",
          Cilindros: "6",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "US/MEX"
        }
      ],
      intercambios: [
        { Intercambio: "32416851217", MarcaOrigen: "BMW", Origen: "OEM" },
        { Intercambio: "39209", MarcaOrigen: "Febi Bilstein", Origen: "Aftermarket" },
        { Intercambio: "314 632 0001", MarcaOrigen: "Meyle", Origen: "Aftermarket" }
      ],
      catalogo: {
        Categoria: "Vehiculo ligero",
        Sistema: "DIRECCIÓN Y SUSPENSIÓN",
        Subsistema: "SISTEMA DE DIRECCIÓN HIDRÁULICA",
        Descripcion: "Depósito de reserva para el fluido de la dirección asistida hidráulica."
      }
    },

    "18107502346-EC" => {
      referencia: "18107502346-EC",
      marca: "Meistersatz",
      producto: "JUNTA DE ESCAPE",
      aplicaciones: [
        {
          Posicion: "Escape",
          Fabricante: "BMW",
          Modelo: "X5",
          Submodelo: "3.0i",
          Ano: 2005,
          Litros: "3.0",
          CC: "2979",
          CID: "182",
          Cilindros: "6",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "GLOBAL"
        },
        {
          Posicion: "Escape",
          Fabricante: "BMW",
          Modelo: "Serie 3",
          Submodelo: "330i",
          Ano: 2003,
          Litros: "3.0",
          CC: "2979",
          CID: "182",
          Cilindros: "6",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "GLOBAL"
        }
      ],
      intercambios: [
        { Intercambio: "18107502346", MarcaOrigen: "BMW", Origen: "OEM" },
        { Intercambio: "71-36066-00", MarcaOrigen: "Victor Reinz", Origen: "Aftermarket" },
        { Intercambio: "804.880", MarcaOrigen: "Elring", Origen: "Aftermarket" }
      ],
      catalogo: {
        Categoria: "Vehiculo ligero",
        Sistema: "SISTEMA DE ESCAPE",
        Subsistema: "JUNTAS DE ESCAPE",
        Descripcion: "Empaque sellador para tubería de escape o múltiple, resistente a altas temperaturas."
      }
    },

    "11361705532" => {
      referencia: "11361705532",
      marca: "Meistersatz",
      producto: "MANGUERA DE ACEITE",
      aplicaciones: [
        {
          Posicion: "Motor",
          Fabricante: "BMW",
          Modelo: "Serie 3",
          Submodelo: "323i",
          Ano: 1999,
          Litros: "2.5",
          CC: "2494",
          CID: "152",
          Cilindros: "6",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "US/MEX"
        },
        {
          Posicion: "Motor",
          Fabricante: "BMW",
          Modelo: "Z3",
          Submodelo: "2.8",
          Ano: 1998,
          Litros: "2.8",
          CC: "2793",
          CID: "170",
          Cilindros: "6",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "GLOBAL"
        }
      ],
      intercambios: [
        { Intercambio: "11361705532", MarcaOrigen: "BMW", Origen: "OEM" },
        { Intercambio: "CRP-11361705532", MarcaOrigen: "Rein", Origen: "Aftermarket" },
        { Intercambio: "V20-1383", MarcaOrigen: "Vaico", Origen: "Aftermarket" }
      ],
      catalogo: {
        Categoria: "Vehiculo ligero",
        Sistema: "MOTOR",
        Subsistema: "LUBRICACIÓN DE MOTOR (VANOS)",
        Descripcion: "Línea de presión de aceite para sistema de sincronización variable de válvulas (VANOS)."
      }
    },

    "33326768724-EC" => {
      referencia: "33326768724-EC",
      marca: "Meistersatz",
      producto: "HORQUILLA",
      aplicaciones: [
        {
          Posicion: "Suspensión Trasera",
          Fabricante: "BMW",
          Modelo: "Serie 3",
          Submodelo: "320i",
          Ano: 2012,
          Litros: "2.0",
          CC: "1997",
          CID: "121",
          Cilindros: "4",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "GLOBAL"
        },
        {
          Posicion: "Suspensión Trasera",
          Fabricante: "BMW",
          Modelo: "Serie 1",
          Submodelo: "128i",
          Ano: 2010,
          Litros: "3.0",
          CC: "2996",
          CID: "182",
          Cilindros: "6",
          Bloque: "L",
          Combustible: "Gasolina",
          Mercado: "GLOBAL"
        }
      ],
      intercambios: [
        { Intercambio: "33326768724", MarcaOrigen: "BMW", Origen: "OEM" },
        { Intercambio: "33902 01", MarcaOrigen: "Lemförder", Origen: "OEM Supplier" },
        { Intercambio: "TC2477", MarcaOrigen: "Delphi", Origen: "Aftermarket" },
        { Intercambio: "316 050 0048", MarcaOrigen: "Meyle", Origen: "Aftermarket" }
      ],
      catalogo: {
        Categoria: "Vehiculo ligero",
        Sistema: "DIRECCIÓN Y SUSPENSIÓN",
        Subsistema: "BRAZOS Y HORQUILLAS DE SUSPENSIÓN",
        Descripcion: "Brazo de control de suspensión (horquilla) con bujes preinstalados, mantiene la alineación de la rueda."
      }
    }
  }.freeze

  def self.lookup(sku)
    MOCK_DATA[sku] || {
      referencia: sku,
      marca: "N/A",
      producto: "N/A",
      aplicaciones: [],
      intercambios: [],
      catalogo: { Categoria: "N/A", Sistema: "N/A", Subsistema: "N/A", Descripcion: "N/A" }
    }
  end
end
