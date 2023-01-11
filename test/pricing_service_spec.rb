# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/pricing_service'

RSpec::Sorbet.allow_doubles!

RSpec.describe PricingService do
  let(:item) { instance_double(Item, code: 'ITM1', price: 3.0) }

  describe '#calculate_line_item' do
    context 'when there are no discounts' do
      subject(:pricing_service) { PricingService.new }
      it 'calculates the original price if there is no discount' do
        expect(pricing_service.calculate_line_item(item:, quantity: 2)).to eq(6.0)
      end
    end
  end
end
