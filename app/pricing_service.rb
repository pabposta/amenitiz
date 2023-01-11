# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative 'item'

class PricingService
  extend T::Sig

  sig { params(item: Item, quantity: Integer).returns(Float) }
  def calculate_line_item(item:, quantity:)
    item.price * quantity
  end
end
