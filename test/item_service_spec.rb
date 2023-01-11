# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/item_service'

RSpec::Sorbet.allow_doubles!

RSpec.describe ItemService do
  subject(:item_service) do
    datastore_adapter = instance_double(DatastoreAdapter,
                                        items: [Item.new(code: 'ITM1', name: 'Item 1', price: 10.0,
                                                         currency: '€')])
    ItemService.new(datastore_adapter:)
  end

  describe '#item' do
    it 'returns the corresponding item, when given a code' do
      item = item_service.item(item_code: 'ITM1')
      expect(item).to eq(Item.new(code: 'ITM1', name: 'Item 1', price: 10.0, currency: '€'))
    end

    it 'raises an error when an inexistent code is requested' do
      expect { item_service.item(item_code: 'ITM0') }.to raise_error(ArgumentError, 'Item code ITM0 does not exist')
    end
  end

  describe '#exists?' do
    it 'returns true if an item exists' do
      expect(item_service.exists?(item_code: 'ITM1')).to be(true)
    end

    it 'returns false if an item does not exist' do
      expect(item_service.exists?(item_code: 'ITM0')).to be(false)
    end
  end
end
