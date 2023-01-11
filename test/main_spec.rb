# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../main'

RSpec::Sorbet.allow_doubles!

RSpec.describe 'main' do
  let(:datastore_adapter) { instance_double(DatastoreAdapter) }
  let(:item_service) { instance_double(ItemService) }
  let(:discount_factory) { instance_double(DiscountFactory) }
  let(:pricing_service) { instance_double(PricingService) }
  let(:basket) { instance_double(Basket) }
  let(:initial_prompt_state) { instance_double(HomePromptState) }
  let(:user_interface) { instance_double(UserInterface) }

  it 'runs the main program' do
    expect(DatastoreAdapter).to receive(:new).and_return(datastore_adapter)
    expect(ItemService).to receive(:new).with(datastore_adapter:).and_return(item_service)
    expect(DiscountFactory).to receive(:new).and_return(discount_factory)
    expect(PricingService).to receive(:new).with(
      datastore_adapter:,
      discount_factory:
    ).and_return(pricing_service)
    expect(Basket).to receive(:new).with(
      item_service:,
      pricing_service:
    ).and_return(basket)
    expect(HomePromptState).to receive(:new).with(basket:).and_return(initial_prompt_state)
    expect(UserInterface).to receive(:new).with(
      basket:,
      initial_prompt_state:
    ).and_return(user_interface)
    expect(user_interface).to receive(:run)
    main
  end
end
