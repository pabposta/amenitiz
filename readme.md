# Intro
This is the documentation for my presentation of the Amenitiz interview task to replicate a basket which allows to add items with discounts.

# Instructions
## Setup
The challenge is written in Ruby and expects Ruby 3.2.0. This assumes rbenv is installed.
```
rbenv install 3.2.0
cd <app dir>
rbenv local 3.2.0
rbenv rehash
gem install bundler
bundle install
tapioca init (optional, for Sorbet)
```

## Tests
To run the tests, run
`bundle exec rake test`

The test case outline in the task description can be found at `test/test_data_spec.rb`.

## The app
To run the app and use the UI, run
`bundle exec ruby main.rb`

## Tools
Two support tools for coding style and correctness are used: Sorbet and Rubocop. Sorbet allows to introduce type checking, avoiding unexpected types to be passed and making the intent clearer to any reader and Rubocop can autoformat and find code smells that could impact functionality or ease of use negatively.

### Sorbet
Sorbet checks types at runtime, but can also do a static check with
`bundle exec srb tc`

### Rubocop
To run Rubocop, run
`bundle exec rubocop -a (or -A)`
The -a and -A parameters autocorrect errors. -a is safer but skips some corrections.

# Design
The task calls for a simple application that is usable, maintainable and extendable.

To achieve these goals, several techniques were applied:
- Classes have only a single responsibility, so that they are short and it is clear what they do
- Methods are short as well, so that they can be easily understood
- Names are chosen with the intent of being descriptive and consistent
- Dependency injection is used almost everywhere to facilitate changes and testing, as well as loose coupling
- Other design patterns are used as well, most of which are aimed at allowing to easily extend the code
- This results in classes that can be easily replaced with a compatible interface, e.g., to fetch data from a database instead of hard-coding it

There is an additional functionality that allows to remove items. I had asked if additional functionality to improve the user experience was part of the task, even if not mentioned explicitly, and the interviewer said it was OK to add it.

## The process
The first step was to analyze the problem and lay out a design, with which actions and interfaces were needed and translate them to likely classes and methods. The user interface was left as the last step and first the core business logis was implemented.

The implementation was done using TDD, as instructed. This means no code was written that was not in (failing) test before. As a result, the tests cover the entire code, including the UI and main loop.

Code formatting was done using Rubocop and Sorbet was used for type-checking. The user interface is built on the TTY toolkit.

# Class breakdown
These class notes can also be found in the code itself, but they are repeated here for convenience.

## main
Not a class, but the main entry point to the app. It creates all components with the test data from the task description and feeds them to the UI so it can run until the user chooses to stop it by using the Exit option.

## Basket
This class represents a basket of items. It is responsible for tracking how many items a user has and how much they cost in total. It is also the main class a user interacts with. A user can add an item to it, remove an item, as well as access the line items (a view of an item combined with quantity and total price), the total price sum of the basket and the item service, which is used as the source for the item data.

Removing an item is not part of the task, but a simple addition that improves the user experience. I had asked my contact whether such functionalities should be added and they said it's not necessary but OK.

## Datastore Adapter
This class is responsible for interacting with a data store. In this case it is hardcoded, but using the interface, it could easily be used to get the data from other sources, like a file or a database.

In this case, it could be for example a CsvDatastoreAdapter, or MysqlDatastoreAdatper, etc. It could also be split to get the items from one source and the discounts from another. This way, the main program is decoupled from the data source.

The adapter allows to get items and discounts from the store.

## Discounts
Everything related to discounts.

### Discount
This module serves as an interface for discounts. The discounts can be applied to a price and return the discounted price per unit, taking the quantity into account. Using the unit price and not the total price allows for easy chaining of discounts.

### BuyXGetYFreeDiscount
This is a more general version of the buy 1 get 1 free discount. Given the two parameters, it will discount any free units, for example, buy 3 get 2 free would allow to get 5 units for the price of 3.

If a full batch (3 + 2 = 5) is not completed, it will apply the discount "partially", e.g., if 4 units are bought in this example, the price is the same as for 5 units (which is 3 units). 3 or less units pay full unit price.

### FixedPriceBulkDiscount
This discount sets the price of all items of the same code to fixed lower price if a minimum quantity (bulk quantity) is reached. An item that might cost 5.00€ per unit could be discounted to 4.00€ per unit if at least 3 are bought, for example.

### FractionPriceBulkDiscount
This discount sets the price of all items of the same code to a fraction of the original price if a minimum quantity (bulk quantity) is reached. An item that might cost 5.00€ per unit could be discounted by 20% if at least 3 are bought, for example.

The fraction is a decimal multiplier of the original price, so a 20% discount would be a 0.8 fraction.

### DiscountFactory
This class is responsible for creating a new discount based on the parameters. Discounts are stored with their parameters in the datastore. This factory will then transform such a parameter set into a discount object that can then be used by the pricing service. This makes changing or adding new discounts easy.

A new discount will only require a new discount class and an entry in the factory. Changing discounts (or the items they apply to) is then mostly a matter of configuration in the datastore and requires no code changes.

Storing the discounts in a separate collection also makes it easy to create a history, if start and end dates are added to each entry.

If a discount definition is invalid (or unknown), it will raise an error.

## ItemService
The item service (or manager) is responsible for holding and serving the item information, i.e., code, name, unit price, etc. It can return an item given a code and respond the question whether a given item code exists. It acts as a glorified hash in this simple case, but can already build itself from the datastore adapter and can be extended much more easily.

## Item
A simple data structure to hold the item information. It is essentially a hash, but has the advantage of having a formal definition, which makes understanding and working with it a bit easier and safer, as well as allowing to extend it more easily.

## LineItem
A simple data structure to hold the item information. It is essentially a hash, but has the advantage of having a formal definition, which makes understanding and working with it a bit easier and safer, as well as allowing to extend it more easily.

## PricingService
The pricing service (or manager) is responsible for calculating line item prices, as well as the total price. The total price is simply the sum of the line items at the moment, but having the calculations done here allows for easy addition of basket wide discounts.

The line item price calculation consists mostly in applying any discounts that might be relative for the item, and then the simple multiplication of quantity and unit price. There is currently only one discount per item, but chaining them could be done easily by looping over an array of discounts and feeding in the price of the previous iteration (if the discount logic allows for this).

All prices are rounded to two decimals, to represent how they are treated in reality (at least with Euros). Line items are also rounded here, and not only in the UI, to avoid mismatches because of rounding errors of displayed line item total and the basket total, e.g., 1.114 + 2.323 = 3.437 -> 3.44, but the user would see 1.11 + 2.32, which should be 3.43 and not 3.44.

## Prompts
Everything related to prompts

### PromptState
Abstract state class of the prompt. The prompt asks for user input and can show several options. Each prompt state will show one of those options, process the answer and move on the next prompt (state).

For example, the main "menu" will prompt for an action, like adding or removing an item. Depending on the choice, a prompt to select an item to add or remove it will be shown, and from there it's back to the main menu.

### ScanPromptState
In this prompt we can select an item from the list of available items and add it (one unit of it) to the basket. We can also cancel and go back to the home screen.

### RemovePromptState
In this prompt we can select an item from the list of items in the basket and remove it (one unit of it) from the basket. We can also cancel and go back to the home screen.

### ExitPromptState
This is the exit state which only tells the main program that we want to exit

## UserInterface
This class present an interactive user interface in the terminal. It is menu driven and supports navigation with the arrow keys and the enter key. It shows the basket (a special message is shown if the basket is empty) and a prompt to interact with it (scan (add) and remove items, as well as exit).

The basket is represented by a table that shows its line items and the total sum.

The UI loops in showing the basket and the prompt, which allows the user to perform actions, until the user selects the exit option.
