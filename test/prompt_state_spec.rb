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
