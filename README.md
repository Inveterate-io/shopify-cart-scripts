# Shopify Cart Scripts

A bunch of scripts for merchants to use in relation to Inveterate in the Shopify Script Editor app.

[Script Editor App](https://apps.shopify.com/script-editor)
[Script Editor Docs](https://help.shopify.com/en/manual/checkout-settings/script-editor/shopify-scripts)

## Custom Scripts

### Shipping Scripts

- free_shipping_by_shipping_code.rb: Gives free shipping based on the name of the shipping code
- free_shipping_pid.rb: Free shipping based on product ID

### Line Item Scripts
- member_only_pricing_ppid.rb: Member only pricing utilizing a list of product IDs providing a percentage off discount to individual line items
- member_only_pricing_fpid.rb: Member only pricing utilizing a list of product IDs providing a fixed amount discount to individual line items
- member_only_pricing_complete_tag_solution.rb: A completely flexible solution for member only pricing that allows the merchant to utilize pre-defined tags to provide any percent or fixed price discount on an individual product basis
- member_only_pricing_ptag: Provides a specific percentage discount to individual line items that have the specified tag
- member_only_pricing_ftag: Provides a specific fixed amount discount to individual line items that have the specified tag
- pre_member_only_pricing_complete_tag_solution: Applies the complete tag solution for member only pricing to non-members who have the membership product in their cart.
