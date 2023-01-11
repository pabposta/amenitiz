# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/pricing_service'

RSpec::Sorbet.allow_doubles!

RSpec.describe PricingService do
  let(:item) { instance_double(Item, code: 'ITM1', price: 3.0) }

  describe '#calculate_line_item' do
    context 'when there are no discounts' do
      subject(:pricing_service) do
        datastore_adapter = instance_double(DatastoreAdapter, discounts: [])
        discount_factory = instance_double(DiscountFactory)
        PricingService.new(datastore_adapter:,
                           discount_factory:)
      end
      it 'calculates the original price if there is no discount' do
        expect(pricing_service.calculate_line_item(item:, quantity: 2)).to eq(6.0)
      end
    end

    context 'when there is a discount' do
      subject(:pricing_service) do
        datastore_adapter = instance_double(DatastoreAdapter,
                                            discounts: [{ "name": 'dummy', "item_code": 'ITM1' }])
        discount = instance_double(Discount, apply: 2.5)
        discount_factory = instance_double(DiscountFactory, create_discount: discount)
        PricingService.new(datastore_adapter:,
                           discount_factory:)
      end

      it 'applies the discount if it is for the item' do
        expect(pricing_service.calculate_line_item(item:, quantity: 2)).to eq(5.0)
      end

      it 'does not apply the discount if it is not for the item' do
        expect(pricing_service.calculate_line_item(item: instance_double(Item, code: 'ITM2', price: 3.0),
                                                   quantity: 2)).to eq(6.0)
      end
    end

    subject(:pricing_service) do
      datastore_adapter = instance_double(DatastoreAdapter, discounts: [])
      discount_factory = instance_double(DiscountFactory)
      PricingService.new(datastore_adapter:,
                         discount_factory:)
    end

    it 'rounds the result to two decimals' do
      expect(item).to receive(:price).and_return(1.1111)
      expect(pricing_service.calculate_line_item(item:, quantity: 2)).to eq(2.22)
    end
  end
end
