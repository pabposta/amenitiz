# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/basket'

RSpec.describe Basket do
  subject(:basket) { Basket.new }

  describe '#add_item' do
    it 'allows to add items' do
    end

    it 'raises an error when trying to add an item that does not exist' do
    end
  end

  describe '#remove_item' do
    it 'allows to delete items' do
    end

    it 'raises an error when trying to remove an item that is not in the basket' do
    end
  end

  describe '#line_items' do
    it 'returns the line items' do
    end
  end

  describe '#total_discounted_price' do
    it 'returns the total discounted price of the basket' do
    end
  end
end
