# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/discount'

RSpec.describe BuyXGetYFreeDiscount do
  context 'when buying one and getting one free' do
    subject(:discount) { BuyXGetYFreeDiscount.new(buy: 1, get_free: 1) }

    describe '#apply' do
      it 'applies 50% discount for an even number of items' do
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 2)).to eq(5.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 4)).to eq(5.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 6)).to eq(5.0)
      end

      it 'applies no discount for a single item above an even number' do
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 1)).to eq(10.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 3)).to eq(20.0 / 3.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 5)).to eq(6.0)
      end
    end
  end

  context 'when buying three and getting two free' do
    subject(:discount) { BuyXGetYFreeDiscount.new(buy: 3, get_free: 2) }

    describe '#apply' do
      it 'applies 40% discount for multiples of 5 items' do
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 5)).to eq(6.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 10)).to eq(6.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 15)).to eq(6.0)
      end

      it 'applies no discount for a items above a multiple of 5' do
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 1)).to eq(10.0 / 1.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 2)).to eq(20.0 / 2.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 3)).to eq(30.0 / 3.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 4)).to eq(30.0 / 4.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 6)).to eq(40.0 / 6.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 7)).to eq(50.0 / 7.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 8)).to eq(60.0 / 8.0)
        expect(discount.apply(original_price_per_unit: 10.0, quantity: 9)).to eq(60.0 / 9.0)
      end
    end
  end
end

RSpec.describe FixedPriceBulkDiscount do
  subject(:discount) { FixedPriceBulkDiscount.new(buy: 3, discounted_price: 3.0) }

  describe '#apply' do
    it 'applies a discount when a bulk quantity is reached' do
      expect(discount.apply(original_price_per_unit: 5.0, quantity: 3)).to eq(3.0)
    end

    it 'does not apply a discount when a bulk quantity is not reached' do
      expect(discount.apply(original_price_per_unit: 5.0, quantity: 2)).to eq(5.0)
    end
  end
end

RSpec.describe FractionPriceBulkDiscount do
  subject(:discount) { FractionPriceBulkDiscount.new(buy: 3, new_price_fraction: 2 / 3.0) }

  describe '#apply' do
    it 'applies a discount when a bulk quantity is reached' do
      expect(discount.apply(original_price_per_unit: 6.0, quantity: 3)).to eq(4.0)
    end

    it 'does not apply a discount when a bulk quantity is not reached' do
      expect(discount.apply(original_price_per_unit: 5.0, quantity: 2)).to eq(5.0)
    end
  end
end

RSpec.describe DiscountFactory do
  subject(:discount_factory) { DiscountFactory.new }

  describe '#create_discount' do
    context 'when the name is for BuyXGetYFreeDiscount' do
      let(:name) { 'buy_x_get_y_free' }

      it 'creates the discount when the parameters are valid' do
        discount_definition = {
          name:,
          parameters: {
            buy: 3,
            get_free: 2
          }
        }
        expect(BuyXGetYFreeDiscount).to receive(:new).with(buy: 3, get_free: 2).and_call_original
        discount_factory.create_discount(discount_definition:)
      end

      it 'raises an error when the parameters are invalid' do
        discount_definition = {
          name:,
          parameters: {
            buy: 'invalid',
            get_free: 2
          }
        }
        expect do
          discount_factory.create_discount(discount_definition:)
        end.to raise_error(ArgumentError,
                           'The parameters buy: invalid, get_free: 2 for BuyXGetYFreeDiscount are not valid')

        discount_definition = {
          name:,
          parameters: {
            buy: 1
          }
        }
        expect do
          discount_factory.create_discount(discount_definition:)
        end.to raise_error(ArgumentError,
                           'The parameters buy: 1, get_free: nil for BuyXGetYFreeDiscount are not valid')
      end
    end

    context 'when the name is for FixedPriceBulkDiscount' do
      let(:name) { 'fixed_price_bulk' }

      it 'creates the discount when the parameters are valid' do
        discount_definition = {
          name:,
          parameters: {
            buy: 3,
            discounted_price: 2.0
          }
        }
        expect(FixedPriceBulkDiscount).to receive(:new).with(buy: 3, discounted_price: 2.0).and_call_original
        discount_factory.create_discount(discount_definition:)
      end

      it 'raises an error when the parameters are invalid' do
        discount_definition = {
          name:,
          parameters: {
            buy: 'invalid',
            discounted_price: 2.0
          }
        }
        expect do
          discount_factory.create_discount(discount_definition:)
        end.to raise_error(ArgumentError,
                           'The parameters buy: invalid, discounted_price: 2.0 '\
                           'for FixedPriceBulkDiscount are not valid')

        discount_definition = {
          name:,
          parameters: {
            buy: 1
          }
        }
        expect do
          discount_factory.create_discount(discount_definition:)
        end.to raise_error(ArgumentError,
                           'The parameters buy: 1, discounted_price: nil '\
                           'for FixedPriceBulkDiscount are not valid')
      end
    end

    context 'when the name is for FractionPriceBulkDiscount' do
      let(:name) { 'fraction_price_bulk' }

      it 'creates the discount when the parameters are valid' do
        discount_definition = {
          name:,
          parameters: {
            buy: 3,
            new_price_fraction: 0.5
          }
        }
        expect(FractionPriceBulkDiscount).to receive(:new).with(buy: 3,
                                                                new_price_fraction: 0.5).and_call_original
        discount_factory.create_discount(discount_definition:)
      end

      it 'raises an error when the parameters are invalid' do
        discount_definition = {
          name:,
          parameters: {
            buy: 'invalid',
            new_price_fraction: 0.5
          }
        }
        expect do
          discount_factory.create_discount(discount_definition:)
        end.to raise_error(ArgumentError,
                           'The parameters buy: invalid, new_price_fraction: 0.5 '\
                           'for FractionPriceBulkDiscount are not valid')

        discount_definition = {
          name:,
          parameters: {
            buy: 1
          }
        }
        expect do
          discount_factory.create_discount(discount_definition:)
        end.to raise_error(ArgumentError,
                           'The parameters buy: 1, new_price_fraction: nil '\
                           'for FractionPriceBulkDiscount are not valid')
      end
    end

    context 'when the name is invalid' do
      it 'raises an error when there is no name' do
        discount_definition = {}
        expect do
          discount_factory.create_discount(discount_definition:)
        end.to raise_error(ArgumentError, 'A discount name is required')
      end

      it 'raises an error when there the name references no existing discount' do
        discount_definition = {
          name: 'invalid'
        }
        expect do
          discount_factory.create_discount(discount_definition:)
        end.to raise_error(ArgumentError, 'The name invalid is not a valid discount type')
      end
    end
  end
end
