# frozen_string_literal: true

require "test_helper"

module Catalog
  class GenerateFromUploadTest < ActiveSupport::TestCase
    test "returns xlsx bytes for valid upload" do
      file = Rack::Test::UploadedFile.new(
        file_fixture("prueba_tecnica.xlsx"),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )

      result = GenerateFromUpload.call(upload: file)

      assert result[:ok]
      assert result[:data].bytesize.positive?
      assert_equal GenerateFromUpload::FILENAME, result[:filename]
      assert_equal GenerateFromUpload::CONTENT_TYPE, result[:content_type]
    end

    test "returns xlsx with four sheets including Origen" do
      file = Rack::Test::UploadedFile.new(
        file_fixture("prueba_tecnica.xlsx"),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )

      result = GenerateFromUpload.call(upload: file)

      assert result[:ok]
      output = Rails.root.join("tmp/generate_from_upload_test_output.xlsx").to_s
      File.binwrite(output, result[:data])
      workbook = Roo::Spreadsheet.open(output)
      assert_equal ["Origen", "Aplicaciones", "Intercambios", "Catálogo"], workbook.sheets

      origen = workbook.sheet("Origen")
      catalogo = workbook.sheet(workbook.sheets.last)
      assert_equal 6, origen.last_row
      assert_equal 6, catalogo.last_row
      (2..origen.last_row).each do |row_number|
        refute origen.row(row_number).map { |cell| cell.to_s.strip }.all?(&:empty?)
      end
    ensure
      File.delete(output) if defined?(output) && output && File.exist?(output)
    end

    test "returns alert when workbook exceeds bounds" do
      file = Rack::Test::UploadedFile.new(
        file_fixture("prueba_tecnica.xlsx"),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
      original = WorkbookBoundsValidator.method(:call!)
      WorkbookBoundsValidator.define_singleton_method(:call!) do |**|
        raise WorkbookBoundsValidator::LimitExceeded, WorkbookBoundsValidator::OVERSIZE_ALERT
      end

      result = GenerateFromUpload.call(upload: file)

      refute result[:ok]
      assert_equal WorkbookBoundsValidator::OVERSIZE_ALERT, result[:alert]
    ensure
      WorkbookBoundsValidator.define_singleton_method(:call!, original)
    end
  end
end
