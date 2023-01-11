# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'item_service'
require_relative 'line_item'
require_relative 'pricing_service'

class Basket
  extend T::Sig
  attr_accessor :item_service

  sig { params(item_service: ItemService, pricing_service: PricingService).void }
  def initialize(item_service:, pricing_service:)
    @item_service = item_service
    @pricing_service = pricing_service
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
    line_item.total_discounted_price = @pricing_service.calculate_line_item(item: line_item.item,
                                                                            quantity: line_item.count)
  end

  sig { params(item_code: String).void }
  def remove_item(item_code:)
    raise ArgumentError, "Item code #{item_code} is not in basket" unless @line_items_by_code.include?(item_code)

    if @line_items_by_code[item_code].count > 1
      # if there is more than one item, decrease its count
      line_item = @line_items_by_code[item_code]
      line_item.count -= 1
      line_item.total_discounted_price = @pricing_service.calculate_line_item(item: line_item.item,
                                                                              quantity: line_item.count)
    else
      # otherwise, if the item is the only unit left, delete it completely
      @line_items_by_code.delete(item_code)
    end
  end

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
