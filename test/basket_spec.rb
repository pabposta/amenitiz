# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/basket'

RSpec::Sorbet.allow_doubles!

RSpec.describe Basket do
  let(:item1) { instance_double(Item, code: 'ITM1') }
  let(:item2) { instance_double(Item, code: 'ITM2') }
  let(:item_service) { instance_double(ItemService, exists?: true) }
  subject(:basket) { Basket.new(item_service:) }

  describe '#add_item' do
    it 'allows to add items' do
      expect(item_service).to receive(:item).with({ item_code: 'ITM1' }).and_return(item1)
      basket.add_item(item_code: 'ITM1')
      basket.add_item(item_code: 'ITM1')
      expect(item_service).to receive(:item).with({ item_code: 'ITM2' }).and_return(item2)
      basket.add_item(item_code: 'ITM2')
      expect(basket.line_items).to eq([
                                        LineItem.new(item: item1, count: 2, total_discounted_price: 0.0),
                                        LineItem.new(item: item2, count: 1, total_discounted_price: 0.0)
                                      ])
    end

    it 'raises an error when trying to add an item that does not exist' do
      expect(item_service).to receive(:exists?).and_return(false)
      expect { basket.add_item(item_code: 'ITM0') }.to raise_error(ArgumentError, 'Item code ITM0 does not exist')
    end
  end

  describe '#remove_item' do
    it 'allows to delete items' do
    end

    it 'raises an error when trying to remove an item that is not in the basket' do
    end
  end

  describe '#line_items' do
    it 'returns the line items sorted alphabetically' do
      expect(item_service).to receive(:item).with({ item_code: 'ITM2' }).and_return(item2)
      basket.add_item(item_code: 'ITM2')
      expect(item_service).to receive(:item).with({ item_code: 'ITM1' }).and_return(item1)
      basket.add_item(item_code: 'ITM1')
      expect(basket.line_items).to eq([
                                        LineItem.new(item: item1, count: 1, total_discounted_price: 0.0),
                                        LineItem.new(item: item2, count: 1, total_discounted_price: 0.0)
                                      ])
    end
  end

  describe '#total_discounted_price' do
    it 'returns the total discounted price of the basket' do
    end
  end
end
