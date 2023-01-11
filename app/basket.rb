# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
class Basket
  extend T::Sig

  sig { params(item_code: String).void }
  def add_item(item_code:); end

  sig { params(item_code: String).void }
  def remove_item(item_code:); end

  sig { returns(T::Array[LineItem]) }
  def line_items; end

  sig { returns(Float) }
  def total_discounted_price; end
end
