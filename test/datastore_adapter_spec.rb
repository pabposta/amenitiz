# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/datastore_adapter'

RSpec.describe DatastoreAdapter do
  subject(:datastore_adapter) { DatastoreAdapter.new }

  describe '#items' do
    it 'returns a hard-coded list of items' do
      expect(datastore_adapter.items).to eq([
                                              Item.new(code: 'GR1', name: 'Green Tea', price: 3.11,
                                                       currency: '€'),
                                              Item.new(code: 'SR1', name: 'Strawberries', price: 5.00,
                                                       currency: '€'),
                                              Item.new(code: 'CF1', name: 'Coffee', price: 11.23,
                                                       currency: '€')
                                            ])
    end
  end

  describe '#discounts' do
    it 'returns a hard-coded list of discounts' do
      expect(datastore_adapter.discounts).to eq([
                                                  { name: 'buy_x_get_y_free', item_code: 'GR1',
                                                    parameters: { buy: 1, get_free: 1 } },
                                                  { name: 'fixed_price_bulk', item_code: 'SR1',
                                                    parameters: { buy: 3, discounted_price: 4.5 } },
                                                  { name: 'fraction_price_bulk', item_code: 'CF1',
                                                    parameters: { buy: 3, new_price_fraction: 2 / 3.0 } }
                                                ])
    end
  end
end
