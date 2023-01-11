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
end
