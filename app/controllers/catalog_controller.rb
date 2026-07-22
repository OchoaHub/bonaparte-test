# frozen_string_literal: true

class CatalogController < ApplicationController
  MAX_UPLOAD_BYTES = 10.megabytes

  def new
  end

  def create
    upload = params[:file]
    unless upload.respond_to?(:original_filename)
      redirect_to root_path, alert: "Selecciona un archivo Excel (.xlsx)."
      return
    end

    unless upload.original_filename.to_s.downcase.end_with?(".xlsx")
      redirect_to root_path, alert: "El archivo debe tener extensión .xlsx."
      return
    end

    if upload.size.to_i > MAX_UPLOAD_BYTES
      redirect_to root_path, alert: "El archivo supera el tamaño máximo permitido."
      return
    end

    input_path = nil
    output_path = nil

    input_path = Rails.root.join("tmp", "catalog_input_#{SecureRandom.hex(8)}.xlsx").to_s
    output_path = Rails.root.join("tmp", "catalog_output_#{SecureRandom.hex(8)}.xlsx").to_s
    File.binwrite(input_path, upload.read)

    Catalog::CatalogPipeline.call(input_path: input_path, output_path: output_path)

    send_data(
      File.binread(output_path),
      filename: "catalogo_generado.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      disposition: "attachment"
    )
  rescue StandardError => e
    Rails.logger.error("Catalog generation failed: #{e.message}")
    redirect_to root_path, alert: "No se pudo generar el catálogo. Verifica el formato del archivo."
  ensure
    File.delete(input_path) if input_path && File.exist?(input_path)
    File.delete(output_path) if output_path && File.exist?(output_path)
  end
end
