if @error.blank?
  json.result "OK" 
else
  json.result "ERROR" 
  json.error @error
end
