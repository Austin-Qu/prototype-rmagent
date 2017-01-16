module Api
  module V1
    class UsersController < ApplicationController

      def login
        @error = ""
        email = params[:email]
        password = params[:password]
        device_id = params[:device_id]
        device_name = params[:device_name]
        verifyonly = params[:verifyonly]
        @user = User.where(:email => email).first
        logger.debug ">> in login"
        if @user.blank?
          # user email not found
          @error_code = 1
          @error = Rails.application.config.error_codes[@error_code][:message]
        else
          # user found
          if not @user.valid_password?(password)
            @error_code = 2
            @error = Rails.application.config.error_codes[@error_code][:message]
          else
            logger.debug ">>>> device_id in database: #{@user.device_id}, new device_id: #{device_id}"
            if ( verifyonly.blank? or verifyonly == 'true' ) and !@user.device_id.nil? # and if the account is old
              if device_id != @user.device_id
                @error_code = 3
                @error = Rails.application.config.error_codes[@error_code][:message]
              end
            else
              @user.device_id = device_id
              @user.device_name = device_name
              @user.save
              logger.debug @user.inspect
              logger.debug @user.errors.inspect
            end
          end
        end
      end


      private

        def inspection_params
          params.require(:inspection).permit(:id, :email, :suburb, :state, :postcode, :property_images, :on_type)
        end

    end
  end
end