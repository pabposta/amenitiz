# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'tty-prompt'
require_relative 'basket'

class PromptState
  extend T::Sig
  extend T::Helpers

  abstract!

  sig { params(basket: Basket).void }
  def initialize(basket:)
    @basket = basket
    @prompt = TTY::Prompt.new
  end

  sig { abstract.returns(PromptState) }
  def prompt; end

  sig { returns(T::Boolean) }
  def exit?
    false
  end
end

class HomePromptState < PromptState
  sig { override.returns(PromptState) }
  def prompt
    line_items = @basket.line_items()
    options = if line_items.empty?
                %w[Scan Exit]
              else
                %w[Scan Remove Exit]
              end
    choice = @prompt.select('What do you want to do?', options)
    next_state_from_choice(choice:)
  end

  protected

  sig { params(choice: String).returns(PromptState) }
  def next_state_from_choice(choice:)
    self
  end
end
