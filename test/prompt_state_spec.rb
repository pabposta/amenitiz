# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/prompt_state'

RSpec::Sorbet.allow_doubles!

RSpec.describe 'HomePromptState' do
  let(:basket) { instance_double(Basket) }
  let(:prompt_state) { HomePromptState.new(basket:) }
  subject(:next_prompt_state) { PromptState.new(basket:) }

  describe '#prompt' do
    let(:prompt) { instance_double(TTY::Prompt) }

    context 'when the basket is empty' do
      it 'show options for adding (scanning) an item and exiting, and returns the next state' do
        expect(basket).to receive(:line_items).and_return([])
        expect(TTY::Prompt).to receive(:new).twice.and_return(prompt)
        expect(prompt).to receive(:select).with('What do you want to do?', %w[Scan Exit]).and_return('Scan')
        expect(prompt_state).to receive(:next_state_from_choice).with(choice: 'Scan').and_return(next_prompt_state)
        expect(prompt_state.prompt).to eq(next_prompt_state)
      end
    end

    context 'when the basket is full' do
      it 'show options for adding (scanning) and removing an item and exiting, and returns the next state' do
        expect(basket).to receive(:line_items).and_return([instance_double(LineItem)])
        expect(TTY::Prompt).to receive(:new).twice.and_return(prompt)
        expect(prompt).to receive(:select).with('What do you want to do?',
                                                %w[Scan Remove Exit]).and_return('Scan')
        expect(prompt_state).to receive(:next_state_from_choice).with(choice: 'Scan').and_return(next_prompt_state)
        expect(prompt_state.prompt).to eq(next_prompt_state)
      end
    end
  end

  describe '#exit?' do
    it 'returns false' do
      expect(prompt_state.exit?).to eq(false)
    end
  end
end

RSpec.describe 'ScanPromptState' do
  let(:basket) { instance_double(Basket) }
  subject(:prompt_state) { ScanPromptState.new(basket:) }

  describe '#prompt' do
    let(:item_service) { instance_double(ItemService) }
    let(:items) do
      [
        instance_double(Item, code: 'ITM1', name: 'Item 1', price: 1.11, currency: '€'),
        instance_double(Item, code: 'ITM2', name: 'Item 2', price: 2.22, currency: '€')
      ]
    end
    let(:choices) do
      [
        "Item 1 (ITM1)\t1.11€",
        "Item 2 (ITM2)\t2.22€",
        'Cancel'
      ]
    end
    let(:prompt) { instance_double(TTY::Prompt) }

    before do
      expect(basket).to receive(:item_service).and_return(item_service)
      expect(item_service).to receive(:items).and_return(items)
      expect(TTY::Prompt).to receive(:new).twice.and_return(prompt)
    end

    it 'allows to add an item from the list' do
      expect(prompt).to receive(:select).with('Which item would you like to scan?',
                                              choices).and_return("Item 1 (ITM1)\t1.11€")
      expect(basket).to receive(:add_item).with({ item_code: 'ITM1' })
      expect(prompt_state.prompt.class).to eq(HomePromptState)
    end

    it 'allows to cancel' do
      expect(prompt).to receive(:select).with('Which item would you like to scan?', choices).and_return('Cancel')
      expect(basket).to_not receive(:add_item)
      expect(prompt_state.prompt.class).to eq(HomePromptState)
    end
  end

  describe '#exit?' do
    it 'returns false' do
      expect(prompt_state.exit?).to eq(false)
    end
  end
end

RSpec.describe 'RemovePromptState' do
  let(:basket) { instance_double(Basket) }
  subject(:prompt_state) { RemovePromptState.new(basket:) }

  describe '#prompt' do
    let(:items) do
      [
        instance_double(Item, code: 'ITM1', name: 'Item 1'),
        instance_double(Item, code: 'ITM2', name: 'Item 2')
      ]
    end
    let(:line_items) do
      [
        instance_double(LineItem, item: items[0]),
        instance_double(LineItem, item: items[1])
      ]
    end
    let(:choices) do
      [
        'Item 1 (ITM1)',
        'Item 2 (ITM2)',
        'Cancel'
      ]
    end
    let(:prompt) { instance_double(TTY::Prompt) }

    before do
      expect(basket).to receive(:line_items).and_return(line_items)
      expect(TTY::Prompt).to receive(:new).twice.and_return(prompt)
    end

    it 'allows to remove an item from the list' do
      expect(prompt).to receive(:select).with('Which item would you like to remove?',
                                              choices).and_return('Item 1 (ITM1)')
      expect(basket).to receive(:remove_item).with({ item_code: 'ITM1' })
      expect(prompt_state.prompt.class).to eq(HomePromptState)
    end

    it 'allows to cancel' do
      expect(prompt).to receive(:select).with('Which item would you like to remove?',
                                              choices).and_return('Cancel')
      expect(basket).to_not receive(:remove_item)
      expect(prompt_state.prompt.class).to eq(HomePromptState)
    end
  end

  describe '#exit?' do
    it 'returns false' do
      expect(prompt_state.exit?).to eq(false)
    end
  end
end
