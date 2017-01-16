Rails.application.config.property_types = %w(Land Unit Apartment Villa Townhouse Duplex House) 
Rails.application.config.sales_types = ["Auction", "Express of Interest", "Private Treaty"] 
Rails.application.config.on_sale_types = ["For Sale", "Sold", "Disabled"] 
Rails.application.config.on_lease_types = ["For Lease", "Leased", "Disabled"]
Rails.application.config.send_to_ipad_types = ["For Sale", "For Lease"] 
Rails.application.config.on_types = ["Sale", "Lease"] 
Rails.application.config.on_types_info = {
  "Sale" => Rails.application.config.on_sale_types, 
  "Lease" => Rails.application.config.on_lease_types
}
