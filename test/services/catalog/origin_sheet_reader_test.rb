# frozen_string_literal: true

require "test_helper"

module Catalog
  class OriginSheetReaderTest < ActiveSupport::TestCase
    test "reads five part records from sample workbook" do
      path = file_fixture("prueba_tecnica.xlsx").to_s
      records = OriginSheetReader.call(path)

      assert_equal 5, records.size
      assert_equal "96353002-FE", records.first.sku
      assert_equal "Meistersatz", records.first.brand
      assert_equal "JUNTA TAPA DE PUNTERIAS", records.first.description
    end
  end
end
