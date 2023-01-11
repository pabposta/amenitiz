# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'tty-cursor'
require 'tty-table'
require_relative 'basket'
require_relative 'prompt_state'

# This class present an interactive user interface in the terminal. It is menu driven and supports navigation with the
# arrow keys and the enter key. It shows the basket (a special message is shown if the basket is empty) and a prompt to
# interact with it (scan (add) and remove items, as well as exit).
# The basket is represented by a table that shows its line items and the total sum.
# The UI loops in showing the basket and the prompt, which allows the user to perform actions, until the user selects
# the exit option.
class UserInterface
  extend T::Sig

  # We need the basket and the initial prompt, which would usually be the home screen
  sig { params(basket: Basket, initial_prompt_state: PromptState).void }
  def initialize(basket:, initial_prompt_state:)
    @basket = basket
    @prompt_state = initial_prompt_state
  end

  # Method to display the basket as a table. A special message is shown if it is empty.
  sig { void }
  def show_basket
    line_items = @basket.line_items()
    table = if line_items.empty?
              TTY::Table.new(['The basket is empty', ''], [['Total', '0.00€']])
            else
              create_line_item_table(line_items:)
            end
    puts(table.render(:ascii))
  end

  # Main loop of the UI. Show basket and prompt until the user wants to exit.
  sig { void }
  def run
    until @prompt_state.exit?
      print(TTY::Cursor.clear_screen)
      print(TTY::Cursor.move_to(0, 0))
      show_basket
      @prompt_state = @prompt_state.prompt
    end
  end

  protected

  # Helper to create the basket table to be displayed
  sig { params(line_items: T::Array[LineItem]).returns(TTY::Table) }
  def create_line_item_table(line_items:)
    header = ['Code', 'Name', 'Quantity', 'Unit Price', 'Total']
    lines = line_items.map do |line_item|
      currency = line_item.item.currency
      [
        line_item.item.code,
        line_item.item.name,
        line_item.count,
        "#{line_item.item.price}#{currency}",
        "#{line_item.total_discounted_price}#{currency}"
      ]
    end
    total = ['Total', '', '', '', "#{@basket.total_discounted_price}#{T.must(line_items[0]).item.currency}"]
    TTY::Table.new(header, [:separator].concat(lines.concat([:separator, total])))
  end
end
