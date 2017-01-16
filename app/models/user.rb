class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :trackable

  validates :verification_code, presence: true, :on => :create
  # validates :activation_code, presence: true
  validate :validate_verification_code, :on => :create
  # validates :password, presence: true, length: { minimum: 8 }
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => {minimum: 8},
                       :on => :create
  validates :password, :confirmation => true,
                       :length => {minimum: 8},
                       :allow_blank => true,
                       :on => :update
  # on create/update
  validates :first_name, :last_name, :mobile, :business_name, :presence => true, :allow_blank => false
  # on update
  #validates :acn, :address, :suburb, :state, :postcode, :presence => true, :allow_blank => false, :on => :update

  attr_accessor :verification_code

  has_many :inspections
  has_many :leads_users, :dependent => :delete_all 
  has_many :leads, through: :leads_users
  has_many :email_templates, :dependent => :delete_all

  after_initialize :init

  def init
    self.enabled ||= true
    self.profile_picture ||= "default_profile_picture.png"
    self.company_logo ||= "default_company_logo.png"
    self.account_type ||= "Free"
  end

  #this method is called by devise to check for "enabled" state of the model
  def active_for_authentication?
    #remember to call the super
    #then put our own check to determine "active" state using 
    #our own "is_active" column
    super and self.enabled?
  end

  def full_name
    self.first_name + " " + self.last_name 
  end

  def validate_verification_code
    verification_code = build_verification_code
    if self.verification_code != verification_code
      errors.add(:verification_code, "is not correct")
    end
  end

  def build_verification_code
    Digest::MD5.hexdigest(self.email).last(6)
  end

  def profile_picture_url
    if self.profile_picture == "default_profile_picture.png"
      "#{Rails.configuration.action_controller.default_url_options[:host]}/assets/#{self.profile_picture}"
    else
      "#{Rails.configuration.action_controller.default_url_options[:host]}/#{self.profile_picture_path}"
    end
  end

  def company_logo_url
    if self.company_logo == "default_company_logo.png"
      "#{Rails.configuration.action_controller.default_url_options[:host]}/assets/#{self.company_logo}"
    else
      "#{Rails.configuration.action_controller.default_url_options[:host]}/#{self.company_logo_path}"
    end
  end

  def profile_picture_path
    "uploads/#{self.id}/#{self.profile_picture}"
  end

  def profile_picture_slash_path
    "/" + profile_picture_path
  end

  def company_logo_path
    "uploads/#{self.id}/#{self.company_logo}"
  end

  def company_logo_slash_path
    "/" + company_logo_path
  end

  def profile_image_dir
    "uploads/#{self.id}/"
  end

  def suburb_state_postcode
    "#{self.suburb}, #{self.state}, #{self.postcode}"
  end


end
