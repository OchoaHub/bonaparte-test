# frozen_string_literal: true

require "test_helper"

module Catalog
  class PartExtractorTest < ActiveSupport::TestCase
    test "strips FE suffix from sku" do
      record = PartExtractor.call(
        sku: "96353002-FE",
        description: "JUNTA TAPA DE PUNTERIAS",
        brand: "Meistersatz"
      )

      assert_equal "96353002", record.part_number
      assert_equal "96353002-FE", record.reference
    end

    test "strips EC suffix from sku" do
      record = PartExtractor.call(
        sku: "18107502346-EC",
        description: "JUNTA DE ESCAPE",
        brand: "Meistersatz"
      )

      assert_equal "18107502346", record.part_number
    end

    test "keeps sku without suffix as part number" do
      record = PartExtractor.call(
        sku: "11361705532",
        description: "MANGUERA DE ACEITE",
        brand: "Meistersatz"
      )

      assert_equal "11361705532", record.part_number
      assert_equal "11361705532", record.reference
    end

    test "defaults empty brand to Meistersatz" do
      record = PartExtractor.call(sku: "11361705532", description: "X", brand: "")

      assert_equal "Meistersatz", record.brand
    end
  end
end
