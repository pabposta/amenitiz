# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'item'

class PricingService
  extend T::Sig

  sig do
    params(datastore_adapter: DatastoreAdapter, discount_factory: DiscountFactory).void
  end
  def initialize(datastore_adapter:, discount_factory:)
    discount_definitions = datastore_adapter.discounts
    @discounts_by_item_code = discount_definitions.map do |discount_definition|
      [discount_definition[:item_code], discount_factory.create_discount(discount_definition:)]
    end.to_h
  end

  sig { params(item: Item, quantity: Integer).returns(Float) }
  def calculate_line_item(item:, quantity:)
    price = item.price
    discount = @discounts_by_item_code[item.code]
    price = discount.apply(original_price_per_unit: price, quantity:) if discount
    price * quantity
  end
end
