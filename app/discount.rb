# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

module Discount
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.params(original_price_per_unit: Float, quantity: Integer).returns(Float) }
  def apply(original_price_per_unit:, quantity:); end
end

class BuyXGetYFreeDiscount
  include Discount
  extend T::Sig

  sig { params(buy: Integer, get_free: Integer).void }
  def initialize(buy:, get_free:)
    @buy = buy.to_i
    @get_free = get_free.to_i
    @batch_size = @buy + @get_free
  end

  sig { override.params(original_price_per_unit: Float, quantity: Integer).returns(Float) }
  def apply(original_price_per_unit:, quantity:)
    # calculate the free items in two steps. first, take the ones completing a batch,
    # e.g., a buy 3 get 2 free batch is made of batches of 5 (3 + 2)
    full_batch_free_items = quantity / @batch_size * @get_free
    # then calculate the remaining part, e.g., in the 3 + 2 scenario above,
    # if we have 9 items, 6 will be paid and 3 will be free
    # the remainder has to exceed the @buy amount, otherwise it will be negative,
    # so we need to limit it to 0
    remaining_free_items = [quantity % @batch_size - @buy, 0].max
    free_items = full_batch_free_items + remaining_free_items
    items_to_pay_for = quantity - free_items
    discounted_total_price = items_to_pay_for * original_price_per_unit.to_f
    discounted_total_price / quantity
  end
end

class FixedPriceBulkDiscount
  include Discount
  extend T::Sig

  sig { params(buy: Integer, discounted_price: Float).void }
  def initialize(buy:, discounted_price:)
    @buy = buy.to_i
    @discounted_price = discounted_price.to_f
  end

  sig { override.params(original_price_per_unit: Float, quantity: Integer).returns(Float) }
  def apply(original_price_per_unit:, quantity:)
    quantity >= @buy ? @discounted_price : original_price_per_unit
  end
end
