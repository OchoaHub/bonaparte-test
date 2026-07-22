# frozen_string_literal: true

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
      output_path = nil

      input_path = Rails.root.join("tmp", "catalog_input_#{SecureRandom.hex(8)}.xlsx").to_s
      output_path = Rails.root.join("tmp", "catalog_output_#{SecureRandom.hex(8)}.xlsx").to_s
      File.binwrite(input_path, @upload.read)

      CatalogPipeline.call(input_path: input_path, output_path: output_path)

      {
        ok: true,
        data: File.binread(output_path),
        filename: FILENAME,
        content_type: CONTENT_TYPE
      }
    rescue StandardError => e
      Rails.logger.error("Catalog generation failed: #{e.message}")
      { ok: false, alert: "No se pudo generar el catálogo. Verifica el formato del archivo." }
    ensure
      File.delete(input_path) if input_path && File.exist?(input_path)
      File.delete(output_path) if output_path && File.exist?(output_path)
    end
  end
end
