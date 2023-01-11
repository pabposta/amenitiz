# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'tty-cursor'
require 'tty-table'
require_relative 'basket'

class UserInterface
  extend T::Sig

  sig { params(basket: Basket).void }
  def initialize(basket:)
    @basket = basket
  end

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

  protected

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
