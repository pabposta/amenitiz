# frozen_string_literal: true

require 'rspec'
require 'rspec/sorbet'
require_relative '../app/user_interface'

RSpec::Sorbet.allow_doubles!

RSpec.describe 'UserInterface' do
  let(:basket) { instance_double(Basket) }
  subject(:user_interface) { UserInterface.new(basket:) }

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
  end
end
