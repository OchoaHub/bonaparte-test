# frozen_string_literal: true

require "fileutils"

module Catalog
  class GenerateFromUpload
    FILENAME = "catalogo_generado.xlsx"
    CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

    def self.call(upload:)
      new(upload).call
    end

    def initialize(upload)
      @upload = upload
    end

    def call
      validation = UploadValidator.call(upload: @upload)
      return validation unless validation[:ok]

      input_path = nil
      generated_path = nil
      output_path = nil

      input_path = Rails.root.join("tmp", "catalog_input_#{SecureRandom.hex(8)}.xlsx").to_s
      output_path = Rails.root.join("tmp", "catalog_output_#{SecureRandom.hex(8)}.xlsx").to_s
      File.binwrite(input_path, @upload.read)

      WorkbookBoundsValidator.call!(path: input_path)
      generated_path = Rails.root.join("tmp", "catalog_generated_#{SecureRandom.hex(8)}.xlsx").to_s
      ExcelCatalogGenerator.new(input_path).call(generated_path)

      output_path = Rails.root.join("tmp", "catalog_output_#{SecureRandom.hex(8)}.xlsx").to_s
      if styled_catalog_upload?(input_path)
        WorkbookSheetMerger.call(
          template_path: input_path,
          data_path: generated_path,
          output_path: output_path
        )
      else
        FileUtils.cp(generated_path, output_path)
      end

      bytes = File.binread(output_path)
      bytes = WorkbookCompactor.call(bytes)

      {
        ok: true,
        data: bytes,
        filename: FILENAME,
        content_type: CONTENT_TYPE
      }
    rescue WorkbookBoundsValidator::LimitExceeded => e
      { ok: false, alert: e.message }
    rescue StandardError => e
      Rails.logger.error("Catalog generation failed: #{e.message}")
      { ok: false, alert: "No se pudo generar el catálogo. Verifica el formato del archivo." }
    ensure
      File.delete(input_path) if input_path && File.exist?(input_path)
      File.delete(generated_path) if generated_path && File.exist?(generated_path)
      File.delete(output_path) if output_path && File.exist?(output_path)
    end

    private

    def styled_catalog_upload?(path)
      sheets = Roo::Spreadsheet.open(path).sheets
      sheets.any? { |name| name.casecmp?("origen") } &&
        sheets.any? { |name| name.casecmp?("catálogo") || name.casecmp?("catalogo") }
    end
  end
end
