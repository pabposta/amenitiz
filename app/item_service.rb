# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'datastore_adapter'
require_relative 'item'

class ItemService
  extend T::Sig
  attr_accessor :items

  sig { params(datastore_adapter: DatastoreAdapter).void }
  def initialize(datastore_adapter:)
    @items = datastore_adapter.items
    @items_by_code = @items.map do |item|
      [item.code, item]
    end.to_h
  end

  sig { params(item_code: String).returns(Item) }
  def item(item_code:)
    item = @items_by_code[item_code]
    raise ArgumentError, "Item code #{item_code} does not exist" unless item

    item
  end

  sig { params(item_code: String).returns(T::Boolean) }
  def exists?(item_code:)
    @items_by_code.include?(item_code)
  end
end
