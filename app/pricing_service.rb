# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'datastore_adapter'
require_relative 'discount'
require_relative 'item'
require_relative 'line_item'

# The pricing service (or manager) is responsible for calculating line item prices, as well as the total price. The
# total price is simply the sum of the line items at the moment, but having the calculations done here allows for
# easy addition of basket wide discounts.
# The line item price calculation consists mostly in applying any discounts that might be relative for the item, and
# then the simple multiplication of quantity and unit price. There is currently only one discount per item, but
# chaining them could be done easily by looping over an array of discounts and feeding in the price of the previous
# iteration (if the discount logic allows for this).
# All prices are rounded to two decimals, to represent how they are treated in reality (at least with Euros). Line
# items are also rounded here, and not only in the UI, to avoid mismatches because of rounding errors of displayed line
# item total and the basket total, e.g., 1.114 + 2.323 = 3.437 -> 3.44, but the user would see 1.11 + 2.32, which
# should be 3.43 and not 3.44.
class PricingService
  extend T::Sig

  # We take the datastore adapter and the discount factory so we can build our discount lookup
  sig do
    params(datastore_adapter: DatastoreAdapter, discount_factory: DiscountFactory).void
  end
  def initialize(datastore_adapter:, discount_factory:)
    discount_definitions = datastore_adapter.discounts
    @discounts_by_item_code = discount_definitions.map do |discount_definition|
      [discount_definition[:item_code], discount_factory.create_discount(discount_definition:)]
    end.to_h
  end

  # Given an item and a quantity, apply a discount if there is one and return the total, i.e.,
  # (discounted) unit price * quantity
  sig { params(item: Item, quantity: Integer).returns(Float) }
  def calculate_line_item(item:, quantity:)
    price = item.price
    discount = @discounts_by_item_code[item.code]
    price = discount.apply(original_price_per_unit: price, quantity:) if discount
    (price * quantity).round(2)
  end

  # Return the total sum of line items
  sig { params(line_items: T::Array[LineItem]).returns(Float) }
  def total_discounted_price(line_items:)
    line_items.map(&:total_discounted_price).sum.to_f.round(2)
  end
end
