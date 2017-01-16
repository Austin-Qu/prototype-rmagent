module Api
  module V1
    # class InspectionsController < Api::BaseController
    class InspectionsController < ApplicationController

      # GET /api/{plural_resource_name}
      def index
        logger.debug "params: #{params.inspect}"
        @inspections = Inspection.where(query_params)
      end

      def get_inspections_by_user
        logger.debug "in get_inspections_by_user..."
        @error = ""
        user_id = params[:user_id]
        device_id = params[:device_id]
        # Return leads if has_leads is true
        @has_leads = params[:has_leads]
        if not User.exists?(user_id)
          @error = "User not found"
        else
          user = User.find(user_id)
          if user.device_id != device_id
            @error = "User with wrong device id"
          else
            @inspections = Inspection.where(:user_id => user_id, :status => Rails.application.config.send_to_ipad_types)
          end
        end
      end

      private

        def inspection_params
          params.require(:inspection).permit(:id, :street_address, :suburb, :state, :postcode, :property_images, :on_type)
        end

      #   def query_params
      #     # this assumes that an album belongs to an artist and has an :artist_id
      #     # allowing us to filter by this
      #     params.permit(:id, :street_address)
      #   end

    end
  end
end