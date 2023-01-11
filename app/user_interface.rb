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
    table = (TTY::Table.new(['The basket is empty', ''], [['Total', '0.00€']]) if line_items.empty?)
    puts(table.render(:ascii))
  end
end
