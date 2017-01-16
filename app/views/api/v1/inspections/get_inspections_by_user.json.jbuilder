if @error.blank?
  json.result "OK" 
else
  json.result "ERROR" 
  json.error @error
end
json.inspections @inspections do |inspection|
  json.extract! inspection, :id, :property_images_url, :on_type
  json.updated_at inspection.updated_at.to_i
  json.full_address "#{inspection.street_address} #{inspection.suburb} #{inspection.state} #{inspection.postcode}"
  if @has_leads == 'true'
    json.leads inspection.inspections_leads do |inspection_lead|
      lead = inspection_lead.lead
      json.extract! lead, :id, :first_name, :last_name, :telephone, :email, :icon
      json.created_at lead.created_at.to_time.to_i
      json.extract! inspection_lead, :offer_price, :rating, :memo
      json.send_file inspection_lead.send_file ? 1: 0
      json.inspection_datetime inspection_lead.inspection_datetime.to_time.to_i unless inspection_lead.inspection_datetime.blank?
    end
  end
end

