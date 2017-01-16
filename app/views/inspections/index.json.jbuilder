json.array!(@inspections) do |inspection|
  json.extract! inspection, :id, :is_sample
  json.url inspection_url(inspection, format: :json)
end
