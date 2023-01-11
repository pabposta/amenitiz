# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'item'

# This class is responsible for interacting with a data store. In this case it is hardcoded, but using the interface,
# it could easily be used to get the data from other sources, like a file or a database. In this case, it could be for
# example a CsvDatastoreAdapter, or MysqlDatastoreAdatper, etc. It could also be split to get the items from one source
# and the discounts from another. This way, the main program is decoupled from the data source.
# The adapter allows to get items and discounts from the store.
class DatastoreAdapter
  extend T::Sig

  # Returns a hard-coded list of items (the ones from the test data example)
  sig { returns(T::Array[Item]) }
  def items
    [
      Item.new(code: 'GR1', name: 'Green Tea', price: 3.11, currency: '€'),
      Item.new(code: 'SR1', name: 'Strawberries', price: 5.00, currency: '€'),
      Item.new(code: 'CF1', name: 'Coffee', price: 11.23, currency: '€')
    ]
  end

  # Returns a hard-coded list of discounts (the ones from the task desciption)
  sig { returns(T::Array[T::Hash[Symbol, T.any(String, T::Hash[Symbol, T.any(Integer, Float)])]]) }
  def discounts
    [
      { name: 'buy_x_get_y_free', item_code: 'GR1', parameters: { buy: 1, get_free: 1 } },
      { name: 'fixed_price_bulk', item_code: 'SR1', parameters: { buy: 3, discounted_price: 4.5 } },
      { name: 'fraction_price_bulk', item_code: 'CF1', parameters: { buy: 3, new_price_fraction: 2 / 3.0 } }
    ]
  end
end
