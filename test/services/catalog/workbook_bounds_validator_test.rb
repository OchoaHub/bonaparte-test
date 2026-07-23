# frozen_string_literal: true

require "test_helper"

module Catalog
  class WorkbookBoundsValidatorTest < ActiveSupport::TestCase
    test "accepts sample workbook within limits" do
      assert_nothing_raised do
        WorkbookBoundsValidator.call!(path: file_fixture("prueba_tecnica.xlsx").to_s)
      end
    end

    test "rejects workbook with too many worksheets" do
      validator = WorkbookBoundsValidator.new(file_fixture("prueba_tecnica.xlsx").to_s)
      workbook_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          #{Array.new(WorkbookBoundsValidator::MAX_WORKSHEETS + 1) { |i| %(<sheet name="S#{i}" sheetId="#{i + 1}" r:id="rId#{i + 1}"/>) }.join}
        </workbook>
      XML

      validator.define_singleton_method(:read_zip_entry) do |_zip, name|
        raise "unexpected entry #{name}" unless name == "xl/workbook.xml"

        workbook_xml
      end

      error = assert_raises(WorkbookBoundsValidator::LimitExceeded) do
        validator.send(:validate_worksheet_count!, nil)
      end
      assert_equal WorkbookBoundsValidator::OVERSIZE_ALERT, error.message
    end
  end
end
