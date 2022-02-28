# Editable Values
PERCENT_OFF = 100
SHIPPING_CODES = [
  "Economy",
  "Standard",
  "Express"
]
MESSAGE = "Discountd shipping for subscribers!"

########
# DO NOT EDIT PAST THIS POINT
########

class InveterateDiscountedShipping 
  def initialize()
    @percent_off = PERCENT_OFF * 0.01
    @shipping_codes = SHIPPING_CODES
    @message = MESSAGE
  end

  def run(shipping_rates, cart)
    @shipping_rates = shipping_rates
    @cart = cart
    start
  end

  private
  
  def start
    @shipping_rates.each do |shipping_rate|
      next unless @cart.customer
      next unless @cart.customer.tags.include? "inveterate-subscriber"
      next unless shipping_rate.source == "shopify"
      next unless @shipping_codes.include? shipping_rate.code
      shipping_rate.apply_discount(
        shipping_rate.price * @percent_off,
        message: @message
      )
    end
  end
end

CAMPAIGNS = [
  InveterateDiscountedShipping.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.shipping_rates, Input.cart)
end

Output.shipping_rates = Input.shipping_rates
