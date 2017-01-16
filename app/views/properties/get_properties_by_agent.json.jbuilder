json.properties @properties do |property|
  json.extract! property, :id, :street_address, :suburb, :state, :postcode, :property_images
end