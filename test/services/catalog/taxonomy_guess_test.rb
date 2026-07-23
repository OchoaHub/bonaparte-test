# frozen_string_literal: true

require "test_helper"

module Catalog
  class TaxonomyGuessTest < ActiveSupport::TestCase
    test "classifies hose descriptions under cooling system" do
      result = TaxonomyGuess.call("MANGUERA DE ACEITE")

      assert_equal "BANDAS Y ENFRIAMIENTO", result[:sistema]
      assert_equal "MANGUERAS Y TUBERÍAS", result[:subsistema]
    end

    test "classifies gasket descriptions under motor" do
      result = TaxonomyGuess.call("JUNTA DE ESCAPE")

      assert_equal "MOTOR", result[:sistema]
      assert_equal "JUNTAS Y EMPAQUES", result[:subsistema]
    end

    test "returns default taxonomy for unknown descriptions" do
      result = TaxonomyGuess.call("DESCONOCIDO")

      assert_equal "GENERAL", result[:sistema]
      assert_equal "Sin clasificar", result[:subsistema]
    end
  end
end
