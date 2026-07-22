# frozen_string_literal: true

module Catalog
  class PartExtractor
    DEFAULT_BRAND = "Meistersatz"
    SUFFIX_PATTERN = /-(?:FE|EC)\z/i

    def self.call(sku:, description:, brand:)
      sku = sku.to_s.strip
      description = description.to_s.strip
      brand = brand.to_s.strip
      brand = DEFAULT_BRAND if brand.empty?

      part_number = sku.sub(SUFFIX_PATTERN, "")
      part_number = sku if part_number.empty?

      PartRecord.new(
        sku: sku,
        description: description,
        brand: brand,
        part_number: part_number,
        reference: sku
      )
    end
  end
end
