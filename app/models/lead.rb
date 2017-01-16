class Lead < ActiveRecord::Base
  has_many :inspections_leads, :dependent => :delete_all
  has_many :inspections, through: :inspections_leads
  has_many :leads_users, :dependent => :delete_all
  has_many :users, through: :leads_users

  validates :first_name, :last_name, :telephone, :icon, presence: true, :allow_blank => false

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def self.as_csv
    col_names = %w(first_name last_name telephone email created_at)
    CSV.generate do |csv|
      csv << col_names
      all.each do |item|
        csv << [item.first_name, item.last_name, item.telephone, item.email, item.created_at_to_local]
      end
    end 
  end

  def avatar
    if self.icon.blank?
      return "avatar/avatar-00.png"
    elsif self.icon.match(/avatar-[\d]{2}.png/)
      return "avatar/#{self.icon}"
    else
      return "avatar/avatar-#{self.icon.rjust(2, '0')}.png"
    end
  end

  # best rating among all inspections
  def rating
    lead_with_best_rating = InspectionsLead.where(:lead_id=>self.id).order(:rating).first
    lead_with_best_rating.blank? ? 0 : lead_with_best_rating.rating
  end

  def visited_suburbs(on_type, user_id)
    logger.debug "in visited_suburbs: on_type: #{on_type}"
    visited_suburbs = Array.new
    inspection_on_type = Rails.application.config.on_type_mapping_leads_inspection[on_type]
    self.inspections_leads.each do |inspection_lead|
      next if inspection_lead.inspection.user_id != user_id
      next if inspection_lead.inspection.on_type != inspection_on_type
      visited_suburbs << inspection_lead.inspection.suburb
    end
    logger.debug "visited_suburbs: #{visited_suburbs.inspect}"
    return visited_suburbs.uniq.sort.join(';')
  end

  def offer_range(on_type, user_id)
    logger.debug "in offer_range: on_type: #{on_type}"
    offer_prices = Array.new
    inspection_on_type = Rails.application.config.on_type_mapping_leads_inspection[on_type]
    self.inspections_leads.each do |inspection_lead|
      next if inspection_lead.inspection.user_id != user_id
      next if inspection_lead.inspection.on_type != inspection_on_type
      offer_prices << inspection_lead.offer_price
    end
    unless offer_prices.blank?
      return "#{display_offer_price(offer_prices.min)} ~ #{display_offer_price(offer_prices.max)}"
    else
      return ''
    end
  end

  def self.upload_file_url(file_path)
    relative_path = file_path.split('/public/uploads')[1]
    URI::encode("#{Rails.configuration.action_controller.default_url_options[:host]}/uploads/#{relative_path}")
  end

  def last_followup(on_type)
    inspection_on_type = Rails.application.config.on_type_mapping_leads_inspection[on_type]
    inspection_leads = Array.new
    self.inspections_leads.each do |inspection_lead|
      next if inspection_lead.inspection.on_type != inspection_on_type
      inspection_leads << inspection_lead
    end
    if inspection_leads.blank?
      return ''
    else
      inspection_leads = inspection_leads.sort_by{|i| i.inspection_datetime}
      return inspection_leads.last
    end
  end

  def created_at_to_local
    self.created_at.strftime('%Y-%m-%d %H:%M:%S %Z')
  end

  private
  def display_offer_price(offer_price)
    "$#{offer_price.to_i}" unless offer_price.blank?
  end



end
