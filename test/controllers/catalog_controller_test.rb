# frozen_string_literal: true

require "test_helper"

class CatalogControllerTest < ActionDispatch::IntegrationTest
  test "create returns generated xlsx" do
    file = fixture_file_upload("prueba_tecnica.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

    post catalog_path, params: { file: file }

    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.media_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
  end
end
