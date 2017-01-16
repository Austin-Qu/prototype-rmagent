class InviteController < ApplicationController
  def index
  end

  def request_invite
    user = User.new
    email = params[:email]
    emails = User.where(:email => email)
    if emails.blank?
      user.email = email
      params[:verification_code] = user.build_verification_code
      UserMailer.request_invite(params).deliver_now
      respond_to do |format|
        format.html { redirect_to "/invite/request_sent"}
      end
    else
      respond_to do |format|
        format.html { 
          flash[:alert] = I18n.t 'user.email_registered'
          @user_params = params
          logger.debug "@user_params: #{@user_params.inspect}"
          render "/invite/index"
        }
      end
    end
  end

  def request_sent
  end
end
