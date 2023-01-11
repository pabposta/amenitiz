# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/line_item'

RSpec::Sorbet.allow_doubles!

RSpec.describe LineItem do
  let(:item) { instance_double(Item) }
  subject(:line_item) { LineItem.new(item:) }
  describe '#==' do
    it 'returns true if item, count and price are equal' do
      expect(line_item == LineItem.new(item:)).to be(true)
    end

    it 'returns false if either item, count or price are not equal' do
      expect(line_item == LineItem.new(item: instance_double(Item))).to be(false)
      expect(line_item == LineItem.new(item:, count: 1)).to be(false)
      expect(line_item == LineItem.new(item:, total_discounted_price: 1.0)).to be(false)
    end
  end
end
