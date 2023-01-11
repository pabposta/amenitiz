# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'datastore_adapter'
require_relative 'item'

# The item service (or manager) is responsible for holding and serving the item information, i.e., code, name, unit
# price, etc. It can return an item given a code and respond the question whether a given item code exists. It acts as
# a glorified hash in this simple case, but can already build itself from the datastore adapter and can be extended
# much more easily.
class ItemService
  extend T::Sig
  attr_accessor :items

  # It initializes itself from the datastore
  sig { params(datastore_adapter: DatastoreAdapter).void }
  def initialize(datastore_adapter:)
    @items = datastore_adapter.items
    @items_by_code = @items.map do |item|
      [item.code, item]
    end.to_h
  end

  # Given an item code, it returns the item. It raises an error if the code does not exist
  sig { params(item_code: String).returns(Item) }
  def item(item_code:)
    item = @items_by_code[item_code]
    raise ArgumentError, "Item code #{item_code} does not exist" unless item

    item
  end

  # Returns whether the given code belongs to an item
  sig { params(item_code: String).returns(T::Boolean) }
  def exists?(item_code:)
    @items_by_code.include?(item_code)
  end
end
