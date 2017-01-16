class Inspection < ActiveRecord::Base
  belongs_to :user
  has_many :inspections_leads, :dependent => :delete_all
  has_many :leads, through: :inspections_leads
  has_many :email_templates, :dependent => :delete_all

  after_initialize :init
  validates :user_id, :street_address, :state, :postcode, :suburb, :on_type, presence: true, :allow_blank => false

  def init
    # self.number  ||= 0.0           #will set the default value only if it's nil
    # self.address ||= build_address #let's you set a default association
    self.send_file = true if self.send_file.nil?
    self.property_files = "" if self.property_files.nil?
    self.property_images = URI::encode("#{Rails.configuration.action_controller.default_url_options[:host]}/assets/default_inspection_image.png") if self.property_images.nil?
  end

  def suburb_state_postcode
    "#{self.suburb}, #{self.state}, #{self.postcode}"
  end

  def get_full_address
    if self.full_address.blank?
      "#{self.street_address.titleize}, #{self.suburb} #{self.state} #{self.postcode}"
    else
      self.full_address
    end
  end

  def property_images_url
    if self.property_images.start_with?("http") or self.property_images.start_with?("//")
      self.property_images
    else
      "#{Rails.configuration.action_controller.default_url_options[:host]}/uploads/#{self.user.id}/#{self.id}/#{self.property_images}"
    end
  end

  def self.upload_file_dir(user_id, inspection_id)
    Rails.root.join('public', 'uploads', user_id.to_s, inspection_id.to_s)
  end

  # Create default inspection(Sale/Lease)
  def self.create_default(on_type, user_id)
    inspection = Inspection.new
    inspection.user_id = user_id
    inspection.street_address = "Edit Address"
    inspection.suburb = "Edit Suburb"
    inspection.state = "State"
    inspection.postcode = "Postcode"
    inspection.on_type = on_type
    inspection.status = on_type == 'Lease' ? 'For Lease' : 'For Sale'
    # inspection.last_updated = Time.zone.now
    return inspection
  end

  def property_file_url(property_file)
    if property_file == "sample_contract.pdf"
      URI::encode("#{Rails.configuration.action_controller.default_url_options[:host]}/#{property_file}")
    else
      URI::encode("#{Rails.configuration.action_controller.default_url_options[:host]}/uploads/#{self.user.id}/#{self.id}/#{property_file}")
    end
  end

  def self.property_file_path(user_id, inspection_id, property_file)
    if property_file == "sample_contract.pdf"
      Rails.root.join('public', property_file)
    else
      Rails.root.join('public', 'uploads', user_id.to_s, inspection_id.to_s, property_file)
    end
  end

  def property_files_to_array
    if self.property_files.blank?
      return Array.new
    else
      return self.property_files.split(',')
    end
  end

  def add_property_file(property_file)
    property_files = self.property_files_to_array << property_file
    self.property_files = property_files.join(',')
  end

end
