# frozen_string_literal: true

class CatalogController < ApplicationController
  def new
  end

  def create
    result = Catalog::GenerateFromUpload.call(upload: params[:file])

    if result[:ok]
      send_data(
        result[:data],
        filename: result[:filename],
        type: result[:content_type],
        disposition: "attachment"
      )
    else
      redirect_to root_path, alert: result[:alert]
    end
  end
end
