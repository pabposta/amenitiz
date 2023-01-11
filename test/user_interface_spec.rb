# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/user_interface'

RSpec::Sorbet.allow_doubles!

RSpec.describe 'UserInterface' do
  let(:basket) { instance_double(Basket) }
  let(:items) do
    [
      instance_double(Item, code: 'ITM1', name: 'Item 1', price: 1.11, currency: '€'),
      instance_double(Item, code: 'ITM2', name: 'Item 2', price: 1.44, currency: '€')
    ]
  end
  let(:line_items) do
    [
      instance_double(LineItem, item: items[0], count: 3, total_discounted_price: 3.33),
      instance_double(LineItem, item: items[1], count: 1, total_discounted_price: 1.44)
    ]
  end
  let(:initial_prompt_state) { instance_double(HomePromptState, exit?: false) }
  subject(:user_interface) { UserInterface.new(basket:, initial_prompt_state:) }

  describe '#show_basket' do
    let(:table) { instance_double(TTY::Table) }
    let(:rendered_table) { instance_double(String) }

    context 'when the basket is empty' do
      it 'shows an empty basket message and a zero total' do
        expect(basket).to receive(:line_items).and_return([])
        expect(TTY::Table).to receive(:new).with(['The basket is empty', ''],
                                                 [['Total', '0.00€']]).and_return(table)
        expect(table).to receive(:render).with(:ascii).and_return(rendered_table)
        expect { user_interface.show_basket }.to output("#{rendered_table}\n").to_stdout
      end
    end

    context 'when there are items in the basket' do
      it 'shows a header, the line items in the basket and their total sum' do
        expect(basket).to receive(:line_items).and_return(line_items)
        expect(basket).to receive(:total_discounted_price).and_return(4.77)
        expect(TTY::Table).to receive(:new).with(
          ['Code', 'Name', 'Quantity', 'Unit Price', 'Total'],
          [
            :separator,
            ['ITM1', 'Item 1', 3, '1.11€', '3.33€'],
            ['ITM2', 'Item 2', 1, '1.44€', '1.44€'],
            :separator,
            ['Total', '', '', '', '4.77€']
          ]
        ).and_return(table)
        expect(table).to receive(:render).with(:ascii).and_return(rendered_table)
        expect { user_interface.show_basket }.to output("#{rendered_table}\n").to_stdout
      end
    end
  end

  describe '#run' do
    let(:cursor) { instance_double(TTY::Cursor) }
    let(:next_prompt_state) { instance_double(PromptState, exit?: false) }
    let(:last_prompt_state) { instance_double(PromptState, exit?: true) }

    before do
      allow(user_interface).to receive(:show_basket)
      allow(initial_prompt_state).to receive(:prompt).and_return(last_prompt_state)
      allow(TTY::Cursor).to receive(:clear_screen)
      allow(TTY::Cursor).to receive(:move_to)
    end

    it 'clears the screen' do
      clear_screen_string = 'clear_screen'
      move_string = 'move'
      expect(TTY::Cursor).to receive(:clear_screen).and_return(clear_screen_string)
      expect(TTY::Cursor).to receive(:move_to).with(0, 0).and_return(move_string)
      expect { user_interface.run }.to output(clear_screen_string + move_string).to_stdout
    end

    it 'shows the basket' do
      expect(user_interface).to receive(:show_basket)
      user_interface.run
    end

    it 'shows a prompt' do
      expect(initial_prompt_state).to receive(:prompt).and_return(last_prompt_state)
      user_interface.run
    end

    it 'runs until the state exits' do
      expect(user_interface).to receive(:show_basket).twice
      expect(initial_prompt_state).to receive(:prompt).and_return(next_prompt_state)
      expect(next_prompt_state).to receive(:prompt).and_return(last_prompt_state)
      user_interface.run
    end
  end
end
