# Editable Values
MESSAGE = 'Member only pricing!'

########
# DO NOT EDIT PAST THIS POINT
########

class InveterateMemberOnlyPricingCTS
  def initialize()
    @message = MESSAGE
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
      product_tags = line_item.variant.product.tags
      tag_match = false
      discount_tag = ''
      product_tags.each do |tag|
        if tag.include? 'inveterate::percentage' or tag.include? 'inveterate::fixed'
          tag_match = true
          discount_tag = tag
          break
        end
      end
      
      next unless tag_match
      
      discount_line_price = get_discount_line_price(line_item, discount_tag)
      
      next unless discount_line_price
      
      line_item.change_line_price(
        discount_line_price,
        message: @message
      )
    end
  end
  
  def get_discount_line_price(line_item, tag)
    tag_chunks = tag.split('::')
    discount_type = tag_chunks[1].downcase
    discount_amount = tag_chunks[2].to_f
    
    return nil unless discount_type
    return nil unless discount_amount
    
    if discount_type == 'percentage'
      discount = (100.0 - discount_amount) * 0.01
      line_item.line_price * discount
    elsif discount_type == 'fixed'
      discount = Money.derived_from_presentment(customer_cents: discount_amount * 100.0)
      line_item.line_price - (discount * line_item.quantity)
    else
      nil  
    end
  end
end

CAMPAIGNS = [
  InveterateMemberOnlyPricingCTS.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart