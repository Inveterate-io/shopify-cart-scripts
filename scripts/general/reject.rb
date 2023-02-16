def reject_discount_code(cart, customer_tag)
  discount_code = cart.discount_code
  customer = cart.customer

  return unless discount_code
  return unless customer
  return unless customer.tags.include?(customer_tag)

  discount_code.reject({ message: 'Better discount being applied' })
end

reject_discount_code(Input.cart, 'inveterate-subscriber')

Output.cart = Input.cart