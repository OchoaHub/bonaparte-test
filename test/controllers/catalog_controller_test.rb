# frozen_string_literal: true

require "test_helper"
require "fileutils"

class CatalogControllerTest < ActionDispatch::IntegrationTest
  test "create returns generated xlsx" do
    file = fixture_file_upload("prueba_tecnica.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

    post catalog_path, params: { file: file }

    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.media_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
  end

  test "create redirects when file is missing" do
    post catalog_path

    assert_redirected_to root_path
    assert_equal "Selecciona un archivo Excel (.xlsx).", flash[:alert]
  end

  test "create rejects non xlsx extension" do
    csv_path = Rails.root.join("tmp/datos_test.csv")
    FileUtils.cp(file_fixture("prueba_tecnica.xlsx"), csv_path)
    file = Rack::Test::UploadedFile.new(csv_path, "text/csv")

    post catalog_path, params: { file: file }

    assert_redirected_to root_path
    assert_equal "El archivo debe tener extensión .xlsx.", flash[:alert]
  end
end
