# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/item'

RSpec.describe Item do
  subject(:item) { Item.new(code: 'ITM1', name: 'Item 1', price: 10.0, currency: '€') }

  describe '#initialize' do
    it 'creates an item with the parameters' do
      expect(item.code).to eq('ITM1')
      expect(item.name).to eq('Item 1')
      expect(item.price).to eq(10.0)
      expect(item.currency).to eq('€')
    end
  end

  describe '#==' do
    it 'equals another item if all parameters are the same' do
      other_item = Item.new(code: 'ITM1', name: 'Item 1', price: 10.0, currency: '€')
      expect(item).to eq(other_item)
    end

    it 'does not equal another item if any parameter is different' do
      other_item = Item.new(code: 'ITM1', name: 'Item 1', price: 10.0, currency: '$')
      expect(item).not_to eq(other_item)
    end
  end
end
