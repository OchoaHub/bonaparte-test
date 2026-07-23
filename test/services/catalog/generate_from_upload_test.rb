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

    test "returns alert when workbook exceeds bounds" do
      file = Rack::Test::UploadedFile.new(
        file_fixture("prueba_tecnica.xlsx"),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
      original = CatalogPipeline.method(:call)
      CatalogPipeline.define_singleton_method(:call) do |**|
        raise WorkbookBoundsValidator::LimitExceeded, WorkbookBoundsValidator::OVERSIZE_ALERT
      end

      result = GenerateFromUpload.call(upload: file)

      refute result[:ok]
      assert_equal WorkbookBoundsValidator::OVERSIZE_ALERT, result[:alert]
    ensure
      CatalogPipeline.define_singleton_method(:call, original)
    end
  end
end
