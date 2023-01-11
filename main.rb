# frozen_string_literal: true

require_relative 'app/basket'
require_relative 'app/datastore_adapter'
require_relative 'app/discount'
require_relative 'app/item_service'
require_relative 'app/pricing_service'
require_relative 'app/prompt_state'
require_relative 'app/user_interface'

def main
  datastore_adapter = DatastoreAdapter.new
  item_service = ItemService.new(datastore_adapter:)
  discount_factory = DiscountFactory.new
  pricing_service = PricingService.new(datastore_adapter:,
                                       discount_factory:)
  basket = Basket.new(item_service:, pricing_service:)
  initial_prompt_state = HomePromptState.new(basket:)
  user_interface = UserInterface.new(basket:, initial_prompt_state:)
  user_interface.run
end

main if __FILE__ == $PROGRAM_NAME
