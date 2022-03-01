# Editable Values
MESSAGE = 'Member only pricing!'
DISCOUNT_PERCENTAGE = 20
PRODUCT_ID_LIST = []

########
# DO NOT EDIT PAST THIS POINT
########

class MemberOnlyPricing 
  def initialize()
    @message = MESSAGE
    @percentage_off = (100 - DISCOUNT_PERCENTAGE) * 0.01
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
      if @product_id_list.size > 0
        unless @product_id_list.include? line_item.variant.product.id
          next
        end
      end
      line_item.change_line_price(
        line_item.line_price * @percentage_off,
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