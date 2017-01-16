class LocationsController < ApplicationController
  def suburb_state_postcode
    if params[:keyword].blank?
      @locations = Location.all
    else
      keyword = params[:keyword].downcase
      @locations = Location.where("suburb like ? or state like ? or postcode like ?", 
        "%#{keyword}%",  "%#{keyword}%",  "%#{keyword}%")
    end
  end
end
