# Editable Values
MESSAGE = "Free shipping for members!"
MINIMUM_PURCHASE_AMOUNT = nil
MINIMUM_QUANTITY_ITEMS = nil
MAXIMUM_SHIPPING_PRICE = nil
PRODUCT_ID_LIST = []
COUNTRY_CODE_LIST = []

########
# DO NOT EDIT PAST THIS POINT
########

class InveterateFreeShipping 
  def initialize()
    @percent_off = 100 * 0.01
    @message = MESSAGE
    @minimum_purchase_amount = MINIMUM_PURCHASE_AMOUNT
    @minimum_quantity_items = MINIMUM_QUANTITY_ITEMS
    @maximum_shipping_price = MAXIMUM_SHIPPING_PRICE
    @product_id_list = PRODUCT_ID_LIST
    @country_code_list = COUNTRY_CODE_LIST
  end

  def run(shipping_rates, cart)
    @shipping_rates = shipping_rates
    @cart = cart
    start
  end

  private

  def check_purchase_amount
    return true unless @minimum_purchase_amount
    min_price = Money.derived_from_presentment(customer_cents:@minimum_purchase_amount)
    return @cart.subtotal_price > min_price
  end

  def check_item_quantity
    return true unless @minimum_quantity_items
    return @cart.line_items.size >= @minimum_quantity_items
  end

  def check_max_shipping_price(shipping_rate)
    return true unless @maximum_shipping_price
    max_shipping_price = Money.derived_from_presentment(customer_cents: @maximum_shipping_price)
    return shipping_rate.price <= max_shipping_price
  end

  def check_product_ids
    return true unless @product_id_list.size > 0
    line_item_ids = @cart.line_items.map do |line_item|
      line_item.variant.product.id
    end
    reduced_array = line_item_ids - @product_id_list
    return true unless reduced_array.size > 0
  end

  def check_countries
    return true unless @country_code_list.size > 0
    return @country_code_list.include? @cart.shipping_address.country_code
  end
  
  def start
    return unless check_purchase_amount
    return unless check_item_quantity
    return unless check_product_ids
    return unless check_countries
    
    @shipping_rates.each do |shipping_rate|
      next unless @cart.customer
      next unless @cart.customer.tags.include? "inveterate-subscriber"
      return unless check_max_shipping_price(shipping_rate)

      shipping_rate.apply_discount(
        shipping_rate.price * @percent_off,
        message: @message
      )
    end
  end
end

CAMPAIGNS = [
  InveterateFreeShipping.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.shipping_rates, Input.cart)
end

Output.shipping_rates = Input.shipping_rates
