# frozen_string_literal: true

module Catalog
  class UploadValidator
    MAX_BYTES = 10.megabytes

    def self.call(upload:)
      new(upload).call
    end

    def initialize(upload)
      @upload = upload
    end

    def call
      return failure("Selecciona un archivo Excel (.xlsx).") unless valid_upload?

      filename = upload_filename
      return failure("Selecciona un archivo Excel (.xlsx).") if filename.blank?

      unless filename.to_s.downcase.end_with?(".xlsx")
        return failure("El archivo debe tener extensión .xlsx.")
      end

      if @upload.size.to_i > MAX_BYTES
        return failure("El archivo supera el tamaño máximo permitido.")
      end

      { ok: true }
    end

    private

    def valid_upload?
      @upload.respond_to?(:read) && (@upload.respond_to?(:original_filename) || @upload.respond_to?(:filename))
    end

    def upload_filename
      if @upload.respond_to?(:original_filename)
        @upload.original_filename
      else
        @upload.filename
      end
    end

    def failure(alert)
      { ok: false, alert: alert }
    end
  end
end
