# Editable Values
MEMBER_MESSAGE = 'Member only pricing!'
PRE_MESSAGE = 'Membership in cart pricing!'

########
# DO NOT EDIT PAST THIS POINT
########

class InveterateMemberOnlyPricingCTS
  def initialize()
    @message = MEMBER_MESSAGE
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

    # Checks if variant id is in tag to provide discount to tag
    if tag_chunks[3]
      variant_id = tag_chunks[3].to_i
      return nil unless line_item.variant.id == variant_id
    end
    
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

class InveteratePreMemberOnlyPricingCTS
  def initialize()
    @message = PRE_MESSAGE
  end

  def run(cart)
    @cart = cart
    start
  end

  private

  def start
    return if @cart.customer and @cart.customer.tags.include? "inveterate-subscriber"
    
    is_membership_in_cart = false

    @cart.line_items.each do |line_item|
      if line_item.variant.product.tags.include? 'inveterate-product'
        is_membership_in_cart = true
        break
      end
    end
    
    return unless is_membership_in_cart
    
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

    # Checks if variant id is in tag to provide discount to tag
    if tag_chunks[3]
      variant_id = tag_chunks[3].to_i
      return nil unless line_item.variant.id == variant_id
    end
    
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
  InveterateMemberOnlyPricingCTS.new(),
  InveteratePreMemberOnlyPricingCTS.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart
