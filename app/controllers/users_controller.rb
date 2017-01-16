class UsersController < ApplicationController

  def apply_now
  end

  def apply

    user = User.new
    email = params[:email]
    emails = User.where(:email => email)
    if emails.blank?
      user.email = email
      params[:verification_code] = user.build_verification_code
      UserMailer.apply(params).deliver_now
      respond_to do |format|
        format.html { redirect_to "/users/email_sent"}
      end
    else
      respond_to do |format|
        format.html { 
          flash[:alert] = I18n.t 'user.email_registered'
          @user_params = params
          logger.debug "@user_params: #{@user_params.inspect}"
          render "/users/apply_now"
        }
      end

    end
  end

  def email_sent
  end

  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
  def update_password
    @user = User.find(current_user.id)
    password = params[:user][:password]
    if password.blank?
      @notification_type = 'danger'
      @message = "Password cannot be blank"
    else 
      if @user.update_with_password(user_params)
        # Sign in the user by passing validation in case their password changed
        sign_in @user, :bypass => true
        @notification_type = 'success'
        @message = "Password updated successfully"
      else
        @notification_type = 'danger'
        @message = @user.errors.full_messages.first
      end 
    end
    respond_to do |format|
      format.js 
    end
  end

  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.required(:user).permit(:password, :password_confirmation, :current_password)
  end

end
