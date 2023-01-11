# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'item_service'
require_relative 'line_item'
require_relative 'pricing_service'

# This class represents a basket of items. It is responsible for tracking how many items a user has and how much they
# cost in total. It is also the main class a user interacts with. A user can add an item to it, remove an item, as well
# as access the line items (a view of an item combined with quantity and total price), the total price sum of the
# basket and the item service, which is used as the source for the item data.
# Removing an item is not part of the task, but a simple addition that improves the user experience. I had asked my
# contact whether such functionalities should be added and they said it's not necessary but OK.
class Basket
  extend T::Sig
  attr_accessor :item_service

  # The item service is the source of item data (code, name, unit price, etc.) and the pricing service calculates the
  # prices and applies any discounts
  sig { params(item_service: ItemService, pricing_service: PricingService).void }
  def initialize(item_service:, pricing_service:)
    @item_service = item_service
    @pricing_service = pricing_service
    @line_items_by_code = {}
  end

  # Given an item code, it will add it (one unit of it) to the basket. It raises an error if an invalid code is passed.
  # The total price is automatically updated.
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

  # Given an item code, it will remove (one unit of) it from the basket. It raises an error if the code does not belong
  # to an item in the basket. The total price is automatically updated.
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

  # Returns the line items sorted alphabetically. A line item is a combined view of the item making up the line
  # (code, name, etc.) and the quantity and (discounted) sum of the price for it
  sig { returns(T::Array[LineItem]) }
  def line_items
    # The alphabetical sort makes the order consistent. This is useful in testing, to ensure tests pass, and for a
    # better user experience, so that the line items are always shown in the same order (although the UI itself
    # could/should take care of this).
    @line_items_by_code.keys.sort.map do |item_code|
      @line_items_by_code[item_code]
    end
  end

  # Returns the total (discounted) sum of all items in the basket
  sig { returns(Float) }
  def total_discounted_price
    @pricing_service.total_discounted_price(line_items: @line_items_by_code.values)
  end
end
