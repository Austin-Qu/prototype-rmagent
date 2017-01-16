module Sample
  def sample_data(user)
    current_user_id = user.id
    agent_email = user.email
    last_updated = Time.zone.now
    agent_phone = "0400000000"


    suburb = "Sample suburb"
    state = "NSW"
    postcode = "2000"
    sale_property_images = "https://realtymate.com.au/assets/sample_sale_inspection_image.jpg"
    lease_property_images = "https://realtymate.com.au/assets/sample_lease_inspection_image.jpg"
    property_files = "sample_contract.pdf"
    vender_email = agent_email
    lead_email = agent_email
    url = ""

    ## 5 buyers, 5 renters
    sale_prices = ["0", "0", "840000", "830000", "820000"]
    lease_prices = ["510", "520", "525", "515", "550"]

    sale_memoes = ["City; Single", "Bondi; Couple;", "North Sydney; In Hurry; Call him;", "City; 3 Person Family;", "Eastwood; Investment;"]
    lease_memoes = ["Student Couple;",  "Single Mother; Home Office", "Working Close; In Hurry;", "Family", "Eastwood; Investment; Short-Term"]

    ##create a new inspection for sale
    sale_insp = Inspection.create!(:street_address => "Sample for sale", :suburb => suburb, :state => state, :postcode => postcode, 
                  :listing_url => url, :on_type => "Sale", :user_id => current_user_id, :last_updated => last_updated, 
                  :property_images => sale_property_images, 
                  :property_files => property_files, 
                  :status => "For Sale", :vender_email => vender_email, 
                  :count_maybe_like => 0, :count_all_registered => 5, :count_latest => 5, :count_potential_buyers => 4, 
                  :count_follow_ups => 4, :last_follow_up_user_id => current_user_id )

    ##create a new inspection for lease
    lease_insp = Inspection.create!(:street_address => "Sample for lease", :suburb => suburb, :state => state, :postcode => postcode, 
                  :listing_url => url, :on_type => "Lease", :user_id => current_user_id, :last_updated => last_updated, 
                  :property_images => lease_property_images, 
                  :property_files => property_files, 
                  :status => "For Lease", :vender_email => vender_email, 
                  :count_maybe_like => 0, :count_all_registered => 5, :count_latest => 5, :count_potential_buyers => 4, 
                  :count_follow_ups => 4, :last_follow_up_user_id => current_user_id )

    ## create leads
    leads = []
    (0..9).each do |idx|
      lead = Lead.create!( :first_name => "Attendee", :last_name => "Sample#{idx}", :telephone => "#{agent_phone[0..-2]}#{idx}", :email => agent_email, :icon => "#{(idx%2)*10+(idx/2)+1}") 
      leads.push(lead)
    end


    ## connect all leads to inspection
    (0..4).each do |idx|
      LeadsUser.create!( :user_id => current_user_id, :lead_id => leads[idx].id, :source => current_user_id, :on_type => "Buyer")
      InspectionsLead.create!( :lead_id => leads[idx].id, :inspection_id => sale_insp.id, :rating => idx, :offer_price => sale_prices[idx],   
      :memo => sale_memoes[idx], :count_inspections => 2, :invited => true, :maybe_liked => true, :inspected => true, :send_file => true, 
      :count_follow_ups => 1, :follow_up_source_id => current_user_id, :inspection_datetime => last_updated, :last_follow_up => last_updated, 
      :last_follow_up_type => Rails.application.config.followup_types[idx])
    end

    ## connect all leads to inspection
    (0..4).each do |idx|
      LeadsUser.create!( :user_id => current_user_id, :lead_id => leads[5+idx].id, :source => current_user_id, :on_type => "Renter")
      InspectionsLead.create!( :lead_id => leads[5+idx].id, :inspection_id => lease_insp.id, :rating => idx, :offer_price => lease_prices[idx],   
      :memo => lease_memoes[idx], :count_inspections => 2, :invited => true, :maybe_liked => true,  :inspected => true, :send_file => true, 
      :count_follow_ups => 1, :follow_up_source_id => current_user_id, :inspection_datetime => last_updated, :last_follow_up => last_updated, 
      :last_follow_up_type => Rails.application.config.followup_types[idx])
    end 
  end

end