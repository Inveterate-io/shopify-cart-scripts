# Editable Values
MESSAGE = '20% off for members only!'
DISCOUNT_FIXED = 100 # Measured in dollars
DISCOUNT_TAG = 'member-only-pricing'

########
# DO NOT EDIT PAST THIS POINT
########

class MemberOnlyPricing 
  def initialize()
    @message = MESSAGE
    @fixed_off = Money.derived_from_presentment(customer_cents: DISCOUNT_FIXED * 100.0)
    @discount_tag = DISCOUNT_TAG
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
      next unless line_item.variant.product.tags.include? @discount_tag
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