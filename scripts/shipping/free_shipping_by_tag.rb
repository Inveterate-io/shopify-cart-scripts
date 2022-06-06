# Editable Values
MESSAGE = "Free shipping for members!"
MINIMUM_PURCHASE_AMOUNT = nil
MINIMUM_QUANTITY_ITEMS = nil
MAXIMUM_SHIPPING_PRICE = nil
PRODUCT_TAG = 'inveterate::free-shipping' # Set to `nil` for all products to qualify for free shipping
CHECK_ALL_PRODUCTS_QUALIFY = true
COUNTRY_CODE_LIST = []

########
# DO NOT EDIT PAST THIS POINT
########

class InveterateFreeShippingByTag 
  def initialize()
    @percent_off = 100 * 0.01
    @message = MESSAGE
    @minimum_purchase_amount = MINIMUM_PURCHASE_AMOUNT
    @minimum_quantity_items = MINIMUM_QUANTITY_ITEMS
    @maximum_shipping_price = MAXIMUM_SHIPPING_PRICE
    @product_tag = PRODUCT_TAG
    @check_all_products_qualify = CHECK_ALL_PRODUCTS_QUALIFY
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

  def check_product_tag
    return true unless @product_tag
    cart_qualifies = false

    if @check_all_products_qualify
      cart_qualifies = @cart.line_items.all? {|line_item| line_item.variant.product.tags.include? @product_tag}
    else
      cart_qualifies = @cart.line_itmes.any? {|line_item| line_item.variant.product.tags.include? @product_tag} 
    end

    return cart_qualifies
  end

  def check_countries
    return true unless @country_code_list.size > 0
    return @country_code_list.include? @cart.shipping_address.country_code
  end
  
  def start
    return unless @cart.customer
    return unless @cart.customer.tags.include? "inveterate-subscriber"
    return unless check_purchase_amount
    return unless check_item_quantity
    return unless check_product_tag
    return unless check_countries
    
    @shipping_rates.each do |shipping_rate|
      return unless check_max_shipping_price(shipping_rate)

      shipping_rate.apply_discount(
        shipping_rate.price * @percent_off,
        message: @message
      )
    end
  end
end

CAMPAIGNS = [
  InveterateFreeShippingByTag.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.shipping_rates, Input.cart)
end

Output.shipping_rates = Input.shipping_rates
