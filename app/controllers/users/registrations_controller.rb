class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  after_filter :add_account 
  # for inserting sample data
  require 'sample'
  include Sample

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name, :state, :business_name, :title, :mobile, :account_type,
      :abn, :acn, :website, :profile_picture, :company_logo, :telephone, :fax, :address, :suburb, :state, :postcode, :country, :introduction, :verification_code, :agreed)
  end

  def add_account
    if resource.persisted? # user is created successfuly
      # resource.accounts.create(attributes_for_account)
      user = resource
      sample_data(user)

    end
  end

  # def after_sign_up_path_for(resource)
  #   '/users/sign_up'
  # end

  # def sign_up(resource_name, resource)
  #   logger.debug "debug.."
    # sign_in(resource_name, resource)
  # end
end