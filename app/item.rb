# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

class Item
  extend T::Sig
  attr_accessor :code, :name, :price, :currency

  sig { params(code: String, name: String, price: Float, currency: String).void }
  def initialize(code:, name:, price:, currency:)
    @code = code
    @name = name
    @price = price
    @currency = currency
  end

  # Allows to compare two items to one another. Useful for testing.
  sig { params(other: Item).returns(T::Boolean) }
  def ==(other)
    @code == other.code && @name == other.name && @price == other.price && @currency == other.currency
  end
end
