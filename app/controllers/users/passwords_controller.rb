class Users::PasswordsController < Devise::PasswordsController
  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    "/users/password_reset_sent"
  end
end
