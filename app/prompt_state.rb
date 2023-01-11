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

class ScanPromptState < PromptState
  sig { override.returns(PromptState) }
  def prompt
    choices_to_code_map = @basket.item_service.items.map do |item|
      ["#{item.name} (#{item.code})\t#{item.price}#{item.currency}", item.code]
    end.to_h
    choice = @prompt.select('Which item would you like to scan?', choices_to_code_map.keys.sort.push('Cancel'))
    if choice != 'Cancel'
      item_code = choices_to_code_map[choice]
      @basket.add_item(item_code:)
    end
    HomePromptState.new(basket: @basket)
  end
end

class RemovePromptState < PromptState
  sig { override.returns(PromptState) }
  def prompt
    choices_to_code_map = @basket.line_items.map do |line_item|
      item = line_item.item
      ["#{item.name} (#{item.code})", item.code]
    end.to_h
    choice = @prompt.select('Which item would you like to remove?', choices_to_code_map.keys.sort.push('Cancel'))
    if choice != 'Cancel'
      item_code = choices_to_code_map[choice]
      @basket.remove_item(item_code:)
    end
    HomePromptState.new(basket: @basket)
  end
end

class ExitPromptState < PromptState
  def initialize; end

  sig { override.returns(PromptState) }
  def prompt
    self
  end

  sig { override.returns(T::Boolean) }
  def exit?
    true
  end
end
