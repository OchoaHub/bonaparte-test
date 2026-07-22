# frozen_string_literal: true

require "test_helper"

module Catalog
  class CatalogWorkbookBuilderTest < ActiveSupport::TestCase
    setup do
      @record = PartRecord.new(
        sku: "96353002-FE",
        description: "JUNTA TAPA DE PUNTERIAS",
        brand: "Meistersatz",
        part_number: "96353002",
        reference: "96353002-FE"
      )
      @sheets = CatalogWorkbookBuilder.call([@record])
    end

    test "origen row contains reference part number and description" do
      sheet = find_sheet("Origen")
      row = sheet[:rows].first

      assert_equal ["96353002-FE", "Meistersatz", "96353002", "JUNTA TAPA DE PUNTERIAS"], row
    end

    test "aplicaciones row matches header width with empty position column" do
      sheet = find_sheet("Aplicaciones")
      row = sheet[:rows].first

      assert_equal SheetHeaders::APLICACIONES.size, row.size
      assert_equal "96353002-FE", row[0]
      assert_equal "Meistersatz", row[1]
      assert_equal "JUNTA TAPA DE PUNTERIAS", row[2]
      assert_nil row[3]
    end

    test "intercambios row uses extracted part number" do
      sheet = find_sheet("Intercambios")
      intercambio_index = SheetHeaders::INTERCAMBIOS.index("Intercambio")

      assert_equal "96353002", sheet[:rows].first[intercambio_index]
    end

    private

    def find_sheet(name)
      @sheets.find { |sheet| sheet[:name] == name }
    end
  end
end
