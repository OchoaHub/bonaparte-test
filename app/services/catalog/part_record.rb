# frozen_string_literal: true

module Catalog
  PartRecord = Struct.new(
    :sku,
    :description,
    :brand,
    :part_number,
    :reference,
    keyword_init: true
  )
end
