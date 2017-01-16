Rails.application.config.leads_filter_types = ['All', 'Rating', 'Followup', 'No Followup', 'Sold'] 
Rails.application.config.filter_types = Rails.application.config.leads_filter_types.dup.insert(1, 'New')
#Rails.application.config.filter_types << 'Inspection Date'
Rails.application.config.followup_types = ['Newly Registered', 'iPad Follow-up', 'Phone Call', 'Email Sent', 'Email Requested', 'Sold',  'Newly Added'] 
Rails.application.config.is_attendee_types = ['Newly Registered', 'iPad Follow-up', 'Phone Call', 'Email Sent', 'Email Requested', 'Sold', 'Newly Added'] 
Rails.application.config.is_followed_up_types = ['iPad Follow-up', 'Phone Call', 'Email Sent', 'Email Requested', 'Sold'] 
Rails.application.config.followup_actions = ['Email now', 'Phone Call', 'Just contracted'] 
Rails.application.config.more_actions = ['New lead', 'Import leads', 'Export leads', 'Delete'] 
Rails.application.config.leads_filter_types = {
  'Buyer' => ['All', 'Sold'],
  'Renter' => ['All', 'Leased'] 
}

Rails.application.config.on_type_mapping_inspection_leads = { 'Sale' => 'Buyer', 'Lease' => 'Renter' }
Rails.application.config.on_type_mapping_leads_inspection = { 'Buyer' => 'Sale', 'Renter' => 'Lease' }

Rails.application.config.leads_filter_types_info = {
  'Sale' => ['All', 'New', 'Rating', 'Follow-up', 'No Follow-up', 'Sold'],
  'Lease' => ['All', 'New', 'Rating', 'Follow-up', 'No Follow-up', 'Leased'] 
}
