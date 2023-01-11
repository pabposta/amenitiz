# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# A simple data structure to hold the item information. It is essentially a hash, but has the advantage of having a
# formal definition, which makes understanding and working with it a bit easier and safer, as well as allowing to
# extend it more easily.
class Item
  extend T::Sig
  attr_accessor :code, :name, :price, :currency

  # The parameters. Currency is mostly ignored and only used for display purposes (as shown in the task description),
  # but could be used for calculations in the future.
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
