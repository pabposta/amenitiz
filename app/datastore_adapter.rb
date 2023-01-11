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
end
