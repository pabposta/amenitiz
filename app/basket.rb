# frozen_string_literal: true
# typed: true

require_relative 'item_service'

require 'sorbet-runtime'
class Basket
  extend T::Sig

  sig { params(item_service: ItemService).void }
  def initialize(item_service:)
    @item_service = item_service
    @line_items_by_code = {}
  end

  sig { params(item_code: String).void }
  def add_item(item_code:)
    raise ArgumentError, "Item code #{item_code} does not exist" unless @item_service.exists?(item_code:)

    unless @line_items_by_code.include?(item_code)
      # if the item is not in the basket yet, add it. for existing items, we only increase the count
      item = @item_service.item(item_code:)
      @line_items_by_code[item_code] = LineItem.new(item:)
    end
    line_item = @line_items_by_code[item_code]
    line_item.count += 1
    line_item.total_discounted_price = 0.0
  end

  sig { params(item_code: String).void }
  def remove_item(item_code:); end

  sig { returns(T::Array[LineItem]) }
  def line_items
    # The alphabetical sort makes the order consistent. This is useful in testing, to ensure tests pass, and for a
    # better user experience, so that the line items are always shown in the same order (although the UI itself
    # could/should take care of this).
    @line_items_by_code.keys.sort.map do |item_code|
      @line_items_by_code[item_code]
    end
  end

  sig { returns(Float) }
  def total_discounted_price; end
end
