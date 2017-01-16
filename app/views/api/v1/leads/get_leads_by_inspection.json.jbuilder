if @error.blank?
  json.result "OK" 
  json.leads @inspection.inspections_leads do |inspection_lead|
    lead = inspection_lead.lead
    json.extract! lead, :id, :first_name, :last_name, :telephone, :email, :icon
    json.extract! inspection_lead, :offer_price, :rating, :memo
    json.send_file inspection_lead.send_file ? 1: 0
    json.inspection_datetime inspection_lead.inspection_datetime.to_time.to_i unless inspection_lead.inspection_datetime.blank?
  end
else
  json.result "ERROR" 
  json.error @error
end
