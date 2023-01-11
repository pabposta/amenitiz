# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'item'

# The line item class represents a line in the basket, which is a combination of an item and its "basket-relevant"
# data, which are the quantity and the total price, which will already have its discounts applied. Similar to the item,
# in this state, it is essentially a formalized hash, for the same reasons: ease of working with and extending it.
class LineItem
  extend T::Sig
  attr_accessor :item, :count, :total_discounted_price

  # The parameters. It points directly to an item.
  sig { params(item: Item, count: Integer, total_discounted_price: Float).void }
  def initialize(item:, count: 0, total_discounted_price: 0.0)
    @item = item
    @count = count
    @total_discounted_price = total_discounted_price
  end

  # Allows to compare two line items to one another. Useful for testing.
  sig { params(other: LineItem).returns(T::Boolean) }
  def ==(other)
    (
        @item == other.item &&
        @count == other.count &&
        @total_discounted_price == other.total_discounted_price
      )
  end
end
