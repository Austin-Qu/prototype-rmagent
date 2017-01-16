class InspectionsLeadsController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def ajax_update
    logger.debug "inspections leads ajax_update..."
    attr_name = params["name"]
    attr_name.slice!("_#{params["pk"]}")
    attr_value = params["value"]
    attr_value.gsub!('$', '') if attr_name == "offer_price"
    @ins_lead = InspectionsLead.find(params["pk"])
    @ins_lead.update_attribute(attr_name, attr_value)
    respond_to do |format|
      format.json { render :json => @ins_lead.to_json }
      format.js
    end
  end

  def delete_inspection_leads
    logger.debug "in delete_inspection_leads..."
    inspection_lead_ids = params[:inspection_lead_ids]
    @inspection = Inspection.find(params[:inspection_id])
    InspectionsLead.destroy_all(id: inspection_lead_ids ) unless inspection_lead_ids.blank?
    @inspections_leads = @inspection.inspections_leads
    logger.debug "before respond_to js"
    respond_to do |format|
      format.js 
    end
  end

  def set_rating
    @inspection_lead_id = params[:inspection_lead_id]
    @rating = params[:rating]
    @inspection_lead = InspectionsLead.find(@inspection_lead_id)
    @inspection_lead.rating = @rating
    @inspection_lead.save

    respond_to do |format|
      format.js 
    end
  end

  private
  def lead_params
    params.require(:inspection_lead).permit(:rating, :offer_price, :memo)
  end

end
