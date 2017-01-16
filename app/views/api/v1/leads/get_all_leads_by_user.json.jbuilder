if @error.blank?
  json.result "OK" 
  json.leads @leads do |lead|
    json.extract! lead, :id, :first_name, :last_name, :telephone, :email, :icon
    json.created_at lead.created_at.to_time.to_i
  end
else
  json.result "ERROR" 
  json.error @error
end
