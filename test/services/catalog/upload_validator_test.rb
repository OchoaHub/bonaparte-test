# frozen_string_literal: true

require "test_helper"
require "fileutils"

module Catalog
  class UploadValidatorTest < ActiveSupport::TestCase
    test "accepts xlsx upload" do
      file = Rack::Test::UploadedFile.new(
        file_fixture("prueba_tecnica.xlsx"),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )

      result = UploadValidator.call(upload: file)

      assert result[:ok]
    end

    test "rejects missing upload" do
      result = UploadValidator.call(upload: nil)

      refute result[:ok]
      assert_equal "Selecciona un archivo Excel (.xlsx).", result[:alert]
    end

    test "rejects non xlsx filename" do
      csv_path = Rails.root.join("tmp/validator_datos.csv")
      FileUtils.cp(file_fixture("prueba_tecnica.xlsx"), csv_path)
      file = Rack::Test::UploadedFile.new(csv_path, "text/csv")

      result = UploadValidator.call(upload: file)

      refute result[:ok]
      assert_equal "El archivo debe tener extensión .xlsx.", result[:alert]
    ensure
      File.delete(csv_path) if csv_path && File.exist?(csv_path)
    end
  end
end
