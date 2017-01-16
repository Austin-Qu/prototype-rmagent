json.leads @leads do |lead|
  json.name  lead.name
  json.email lead.email
end