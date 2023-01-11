# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'item'

class LineItem
  extend T::Sig
  attr_accessor :item, :count, :total_discounted_price

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
