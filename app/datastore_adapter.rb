# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'item'

class DatastoreAdapter
  extend T::Sig

  sig { returns(T::Array[Item]) }
  def items
    [
      Item.new(code: 'GR1', name: 'Green Tea', price: 3.11, currency: '€'),
      Item.new(code: 'SR1', name: 'Strawberries', price: 5.00, currency: '€'),
      Item.new(code: 'CF1', name: 'Coffee', price: 11.23, currency: '€')
    ]
  end

  sig { returns(T::Array[T::Hash[Symbol, T.any(String, T::Hash[Symbol, T.any(Integer, Float)])]]) }
  def discounts
    [
      { name: 'buy_x_get_y_free', item_code: 'GR1', parameters: { buy: 1, get_free: 1 } },
      { name: 'fixed_price_bulk', item_code: 'SR1', parameters: { buy: 3, discounted_price: 4.5 } },
      { name: 'fraction_price_bulk', item_code: 'CF1', parameters: { buy: 3, new_price_fraction: 2 / 3.0 } }
    ]
  end
end
