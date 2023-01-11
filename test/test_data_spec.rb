# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/basket'

RSpec.describe 'Test data' do
  let(:datastore_adapter) { DatastoreAdapter.new }
  let(:discount_factory) { DiscountFactory.new }
  let(:item_service) { ItemService.new(datastore_adapter:) }
  let(:pricing_service) do
    PricingService.new(datastore_adapter:, discount_factory:)
  end
  let(:basket) { Basket.new(item_service:, pricing_service:) }

  it 'calculates 3.11 for GR1, GR1' do
    basket.add_item(item_code: 'GR1')
    basket.add_item(item_code: 'GR1')
    expect(basket.total_discounted_price).to eq(3.11)
  end

  it 'returns 3.11 for GR1, GR1' do
    basket.add_item(item_code: 'GR1')
    basket.add_item(item_code: 'GR1')
    expect(basket.total_discounted_price).to eq(3.11)
  end

  it 'returns 16.61 for SR1, SR1, GR1, SR1' do
    basket.add_item(item_code: 'SR1')
    basket.add_item(item_code: 'SR1')
    basket.add_item(item_code: 'GR1')
    basket.add_item(item_code: 'SR1')
    expect(basket.total_discounted_price).to eq(16.61)
  end

  it 'returns 30.57 for GR1, CF1, SR1, CF1, CF1' do
    basket.add_item(item_code: 'GR1')
    basket.add_item(item_code: 'CF1')
    basket.add_item(item_code: 'SR1')
    basket.add_item(item_code: 'CF1')
    basket.add_item(item_code: 'CF1')
    expect(basket.total_discounted_price).to eq(30.57)
  end
end
