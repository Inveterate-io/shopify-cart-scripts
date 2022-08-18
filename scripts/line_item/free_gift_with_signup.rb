# Editable Values
MESSAGE = 'FREE GIFT FOR SIGNING UP!'

########
# DO NOT EDIT PAST THIS POINT
########

class InveterateFreeGiftWithSignup
  def initialize()
    @message = MESSAGE
    @enable_on_signup = ENABLE_ON_SIGNUP
  end

  def run(cart)
    @cart = cart
    start
  end

  private

  def start
    @customer = @cart.customer
    @line_items = @cart.line_items

    return unless valid_cart?

    discount_gift
  end

  def valid_cart?
    valid = false

    @line_items.each do |line_item|
      if line_item.variant.product.tags.include? 'inveterate-product'
        valid = true
        break
      end
    end

    return valid
  end

  def discount_gift
    @line_items.each do |line_item|
      # Skip if membership product
      next if line_item.variant.product.tags.include? 'inveterate-product'
      # Skip if product is not the free gift
      next unless line_item.variant.product.tags.include? 'inveterate-signup-gift'

      # Check quantity to create new line item if quantity is greater than 1
      new_line_item = nil
      if line_item.quantity > 1
        new_line_item = line_item.split(take: 1)
        @cart.line_items << new_line_item
      else
        new_line_item = line_item
      end

      puts new_line_item.quantity
      # Apply 100% discount
      new_line_item.change_line_price(
        Money.zero,
        message: @message
      )

      # Once discount has been applied once, break out so it doesn't get applied to another product
      break
    end
  end
end

CAMPAIGNS = [
  InveterateFreeGiftWithSignup.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart