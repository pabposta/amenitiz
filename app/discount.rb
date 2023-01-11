# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# This module serves as an interface for discounts. The discounts can be applied to a price and return the discounted
# price per unit, taking the quantity into account. Using the unit price and not the total price allows for easy
# chaining of discounts.
module Discount
  extend T::Sig
  extend T::Helpers
  interface!

  # Abstract method to apply the discount. It takes a unit price and a quantity and returns a new unit price. If the
  # discount does not apply, this will be the original price.
  sig { abstract.params(original_price_per_unit: Float, quantity: Integer).returns(Float) }
  def apply(original_price_per_unit:, quantity:); end
end

# This is a more general version of the buy 1 get 1 free discount. Given the two parameters, it will discount any free
# units, for example, buy 3 get 2 free would allow to get 5 units for the price of 3. If a full batch (3 + 2 = 5) is
# not completed, it will apply the discount "partially", e.g., if 4 units are bought in this example, the price is the
# same as for 5 units (which is 3 units). 3 or less units pay full unit price.
class BuyXGetYFreeDiscount
  include Discount
  extend T::Sig

  # The x (buy) and y (get_free) parameters in the class name
  sig { params(buy: Integer, get_free: Integer).void }
  def initialize(buy:, get_free:)
    @buy = buy.to_i
    @get_free = get_free.to_i
    @batch_size = @buy + @get_free
  end

  # Returns the discounted unit price, if the discount applies, otherwise the original price
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

# This discount sets the price of all items of the same code to fixed lower price if a minimum quantity (bulk quantity)
# is reached. An item that might cost 5.00€ per unit could be discounted to 4.00€ per unit if at least 3 are bought,
# for example
class FixedPriceBulkDiscount
  include Discount
  extend T::Sig

  # The minimum quantity (buy) and new price (discounted_price) parameters
  sig { params(buy: Integer, discounted_price: Float).void }
  def initialize(buy:, discounted_price:)
    @buy = buy.to_i
    @discounted_price = discounted_price.to_f
  end

  # Returns the discounted unit price, if the bulk quantity is reached, otherwise the original price
  sig { override.params(original_price_per_unit: Float, quantity: Integer).returns(Float) }
  def apply(original_price_per_unit:, quantity:)
    quantity >= @buy ? @discounted_price : original_price_per_unit
  end
end

# This discount sets the price of all items of the same code to a fraction of the original price if a minimum quantity
# (bulk quantity) is reached. An item that might cost 5.00€ per unit could be discounted by 20% if at least 3 are
# bought, for example. The fraction is a decimal multiplier of the original price, so a 20% discount would be a 0.8
# fraction.
class FractionPriceBulkDiscount
  include Discount
  extend T::Sig

  # The minimum quantity (buy) and fraction (new_price_fraction) parameters
  sig { params(buy: Integer, new_price_fraction: Float).void }
  def initialize(buy:, new_price_fraction:)
    @buy = buy.to_i
    @new_price_fraction = new_price_fraction.to_f
  end

  # Returns the discounted unit price, if the discount applies, otherwise the original price
  sig { override.params(original_price_per_unit: Float, quantity: Integer).returns(Float) }
  def apply(original_price_per_unit:, quantity:)
    quantity >= @buy ? original_price_per_unit * @new_price_fraction : original_price_per_unit
  end
end

# This class is responsible for creating a new discount based on the parameters. Discounts are stored with their
# parameters in the datastore. This factory will then transform such a parameter set into a discount object that can
# then be used by the pricing service. This makes changing or adding new discounts easy. A new discount will only
# require a new discount class and an entry in the factory. Changing discounts (or the items they apply to) is then
# mostly a matter of configuration in the datastore and requires no code changes. Storing the discounts in a separate
# collection also makes it easy to create a history, if start and end dates are added to each entry.
# If a discount definition is invalid (or unknown), it will raise an error
class DiscountFactory
  extend T::Sig

  # Given a discount definition, it will create the corresponding definition or raise an error
  sig do
    params(discount_definition: T::Hash[Symbol,
                                        T.any(String, T::Hash[Symbol, T.any(Integer, Float)])]).returns(Discount)
  end
  def create_discount(discount_definition:)
    name = discount_definition[:name]
    discount_parameters = T.cast(discount_definition.fetch(:parameters, {}), T::Hash[Symbol, T.untyped])
    case name
    when 'buy_x_get_y_free'
      create_buy_x_get_y_free_discount(discount_parameters:)
    when 'fixed_price_bulk'
      create_fixed_price_bulk_discount(discount_parameters:)
    when 'fraction_price_bulk'
      create_fraction_price_bulk_discount(discount_parameters:)
    when nil
      raise ArgumentError, 'A discount name is required'
    else
      raise ArgumentError, "The name #{name} is not a valid discount type"
    end
  end

  protected

  # Helper to DRY out the error raising for invalid parameters
  sig do
    params(parameter_pairs: T::Array[T::Array[T.any(String, Integer, Float, NilClass)]], cls: Class).returns(T.noreturn)
  end
  def raise_invalid_parameter_error(parameter_pairs:, cls:)
    parameter_string = parameter_pairs.map do |name, value|
      "#{name}: #{value.nil? ? 'nil' : value}"
    end.join(', ')
    raise ArgumentError, "The parameters #{parameter_string} for #{cls.name} are not valid"
  end

  # Create a BuyXGetYFreeDiscount
  sig { params(discount_parameters: T::Hash[Symbol, T.untyped]).returns(BuyXGetYFreeDiscount) }
  def create_buy_x_get_y_free_discount(discount_parameters:)
    buy = discount_parameters[:buy]
    get_free = discount_parameters[:get_free]
    if buy.class != Integer || get_free.class != Integer
      raise_invalid_parameter_error(
        parameter_pairs: [[:buy, buy], [:get_free, get_free]],
        cls: BuyXGetYFreeDiscount
      )
    end
    BuyXGetYFreeDiscount.new(buy:, get_free:)
  end

  # Create a FixedPriceBulkDiscount
  sig { params(discount_parameters: T::Hash[Symbol, T.untyped]).returns(FixedPriceBulkDiscount) }
  def create_fixed_price_bulk_discount(discount_parameters:)
    buy = discount_parameters[:buy]
    discounted_price = discount_parameters[:discounted_price]
    if buy.class != Integer || discounted_price.class != Float
      raise_invalid_parameter_error(
        parameter_pairs: [[:buy, buy], [:discounted_price, discounted_price]],
        cls: FixedPriceBulkDiscount
      )
    end
    FixedPriceBulkDiscount.new(buy:, discounted_price:)
  end

  # Create a FractionPriceBulkDiscount
  sig { params(discount_parameters: T::Hash[Symbol, T.untyped]).returns(FractionPriceBulkDiscount) }
  def create_fraction_price_bulk_discount(discount_parameters:)
    buy = discount_parameters[:buy]
    new_price_fraction = discount_parameters[:new_price_fraction]
    if buy.class != Integer || new_price_fraction.class != Float
      raise_invalid_parameter_error(
        parameter_pairs: [[:buy, buy], [:new_price_fraction, new_price_fraction]],
        cls: FractionPriceBulkDiscount
      )
    end
    FractionPriceBulkDiscount.new(buy:, new_price_fraction:)
  end
end
