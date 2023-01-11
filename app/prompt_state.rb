# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'tty-prompt'
require_relative 'basket'

# Abstract state class of the prompt. The prompt asks for user input and can show several options. Each prompt state
# will show one of those options, process the answer and move on the next prompt (state). For example, the main "menu"
# will prompt for an action, like adding or removing an item. Depending on the choice, a prompt to select an item to
# add or remove it will be shown, and from there it's back to the main menu.
class PromptState
  extend T::Sig
  extend T::Helpers

  abstract!

  # Most prompts require access to a basket
  sig { params(basket: Basket).void }
  def initialize(basket:)
    @basket = basket
    @prompt = TTY::Prompt.new
  end

  # This is the main method that needs overriding
  sig { abstract.returns(PromptState) }
  def prompt; end

  # Indicates whether this is a final state from which we should exit the program
  sig { returns(T::Boolean) }
  def exit?
    false
  end
end

# The "home screen" or "main menu". From here, we branch out to the all of the actions: scanning (adding) an item,
# removing an item and exiting the application.
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

  # Helper to translate the choice into a state
  sig { params(choice: String).returns(PromptState) }
  def next_state_from_choice(choice:)
    case choice
    when 'Scan'
      ScanPromptState.new(basket: @basket)
    when 'Remove'
      RemovePromptState.new(basket: @basket)
    when 'Exit'
      ExitPromptState.new
    else
      raise ArgumentError, "#{choice} is not a valid choice"
    end
  end
end

# In this prompt we can select an item from the list of available items and add it (one unit of it) to the basket. We
# can also cancel and go back to the home screen.
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

# In this prompt we can select an item from the list of items in the basket and remove it (one unit of it) from the
# basket. We can also cancel and go back to the home screen.
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

# This is the exit state which only tells the main program that we want to exit
class ExitPromptState < PromptState
  def initialize; end

  # It's a final state, it just returns itself to conform to the interface
  sig { override.returns(PromptState) }
  def prompt
    self
  end

  # Indicate that we want to exit now
  sig { override.returns(T::Boolean) }
  def exit?
    true
  end
end
