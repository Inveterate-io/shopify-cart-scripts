# Editable Values
MESSAGE = '20% off for members only!'
DISCOUNT_PERCENTAGE = 20
DISCOUNT_TAG = 'member-only-pricing'
ALLOW_DISCOUNT_CODE = true
DISCOUNT_CODE_REJECTION_MESSAGE = 'Discount code cannot be used with this promotion'

########
# DO NOT EDIT PAST THIS POINT
########

class InveterateMemberOnlyPricingPTAG
  def initialize()
    @message = MESSAGE
    @percentage_off = (100 - DISCOUNT_PERCENTAGE) * 0.01
    @discount_tag = DISCOUNT_TAG
    @allow_discount_code = ALLOW_DISCOUNT_CODE
    @discount_code_rejection_message = DISCOUNT_CODE_REJECTION_MESSAGE
  end

  def run(cart)
    @cart = cart
    start
  end

  private

  def start
    return unless is_member? or is_membership_product_in_cart?
    discount_applied = false

    @cart.line_items.each do |line_item|
      next unless line_item.variant.product.tags.include? @discount_tag
      line_item.change_line_price(
        line_item.line_price * @percentage_off,
        message: @message
      )
      discount_applied = true
    end

    if discount_applied and !@allow_discount_code
      reject_discount_code
    end
  end

  def is_member?
    return false unless @cart.customer
    return false unless @cart.customer.tags.include? "inveterate-subscriber"
    return true
  end

  def is_membership_product_in_cart?
    item_in_cart = false
    @cart.line_items.each do |item|
      if item.variant.product.tags.include? "inveterate-product"
        item_in_cart = true
        break
      end
    end
    return item_in_cart
  end

  def reject_discount_code
    discount_code = @cart.discount_code
    return unless discount_code
    discount_code.reject({ message: @discount_code_rejection_message })
  end
end

CAMPAIGNS = [
  InveterateMemberOnlyPricingPTAG.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart