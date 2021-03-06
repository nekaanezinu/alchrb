require 'json'
require 'net/http'
require_relative 'osrs'
require_relative 'runes'

# Items are anything that can be in your inventory.
#
# @author Marcello A. Sabino
class Item
  # Returns the id of the item
  # @return [Integer] the item's id
  attr_reader :id
  # Returns the item's name
  # @return [String] the item's name
  attr_reader :name
  # Returns the Grand Exchange price of the item
  # @return [Integer] the Grand Exchange's price
  attr_reader :price
  # Returns the store's price of the item
  # @return [Integer] the store's price
  attr_reader :store_price
  # Returns the gold pieces from low alching the item
  # @return [Integer] the amount of GP from low alching
  attr_reader :low_alch
  # Returns the golf pieces from high alching the item
  # @return [Integer] the amount of GP from high alching
  attr_reader :high_alch
  # Returns the image url of the item as a string.
  # @return [String] the image url of the item, on Runescape.com
  attr_reader :image

  # Creates a new Item object
  # @param [Integer] id - the id of the Item
  def initialize(id)
    @id = id.to_i
    @name = generate_name
    @price = generate_price
    @store_price = generate_store
    @low_alch = (@store_price * 0.4).to_i
    @high_alch = (@store_price * 0.6).to_i
    @image = generate_image
  end

  # Class method to get the item's id by name
  # @param [String] item_name - the name of the item to search for
  #        the item_name gets capitalized for search.
  # @return [Integer] the item's id
  # @raise RunTimeError if the item doesn't exist
  def self.id_by_name(item_name)
    item_name = item_name.capitalize
    uri = URI(OSRS::SHOP_DATA)
    json = JSON.parse(Net::HTTP.get(uri))
    item_id = 0
    json.each { |id, name| item_id = id if name['name'].eql? item_name }
    raise "Item (#{item_name}) doesn't exist." if item_id.eql? 0
    item_id.to_i
  end

  # Checks if this item's GE price is less than another item's
  # @param [Item] other - the other item to compare to
  # @return [Boolean] true if this item is worth less than the other_item.
  def <(other)
    price < other.price
  end

  # Checks if this item's GE price is greater than another item's
  # @param [Item] other - the other item to compare to
  # @return [Boolean] true if this item is worth less than the other_item.
  def >(other)
    price > other.price
  end

  # Take another item's price and subtract it from this item
  # @param [Item] other - the other item, which price we will subtract from
  # @return [Integer] self.price - other.price
  def -(other)
    price - other.price
  end

  # Take another item's price and add it with this item's price
  # @param [Item] other - the other item, which price we will subtract from
  # @return [Integer] self.price - other.price
  def +(other)
    price + other.price
  end

  private

  # Gets the name of the Item
  # @return the name of the Item
  def generate_name
    uri = URI(OSRS::SHOP_DATA)
    json = JSON.parse(Net::HTTP.get(uri))
    json[@id.to_s]['name']
  end

  # Gets the store price of the Item
  # @return [Integer] the store price of the Item
  def generate_store
    uri = URI(OSRS::SHOP_DATA)
    json = JSON.parse(Net::HTTP.get(uri))
    json[@id.to_s]['store'].to_i
  end

  # Gets the average price of the Item on the GE
  # @return [Integer] the average price on the GE
  def generate_price
    uri = URI(OSRS::GE_JSON + @id.to_s)
    json = JSON.parse(Net::HTTP.get(uri))
    price_to_int(json['item']['current']['price'])
  end

  # Gets the image url of the item.
  # @return the image url of the item as a string.
  def generate_image
    uri = URI(OSRS::GE_JSON + @id.to_s)
    json = JSON.parse(Net::HTTP.get(uri))
    json['item']['icon_large']
  end

  # Turns a price, like 1.9m and converts to an Integer.
  # @param price - the price of an item in string form
  # @return [Integer] the integer form of a price.
  def price_to_int(price)
    price_float = clean_price(price.to_s)
    price_float *= 1_000_000 if price[-1] == 'm'
    price_float *= 1_000 if price[-1] == 'k'
    price_float.to_i
  end

  # Takes a price as a string, and removes any commas.
  # @param [Float] price - the price from the JSON in string form.
  def clean_price(price)
    price.sub(/,/, '').to_f
  end
end
