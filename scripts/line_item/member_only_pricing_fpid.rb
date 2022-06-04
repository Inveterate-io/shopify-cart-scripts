# Editable Values
MESSAGE = 'Member only pricing!'
DISCOUNT_FIXED = 100 # Measured in dollars
PRODUCT_ID_LIST = [7696292020478]

########
# DO NOT EDIT PAST THIS POINT
########

class MemberOnlyPricing 
  def initialize()
    @message = MESSAGE
    @fixed_off = Money.derived_from_presentment(customer_cents: DISCOUNT_FIXED * 100.0)
    @product_id_list = PRODUCT_ID_LIST
  end

  def run(cart)
    @cart = cart
    start
  end

  private

  def start
    return unless @cart.customer
    return unless @cart.customer.tags.include? "inveterate-subscriber"

    @cart.line_items.each do |line_item|
      next unless @product_id_list.include? line_item.variant.product.id
      line_item.change_line_price(
        line_item.line_price - (@fixed_off * line_item.quantity),
        message: @message
      )
    end
  end
end

CAMPAIGNS = [
  MemberOnlyPricing.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart