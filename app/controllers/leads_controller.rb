class LeadsController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter  :verify_authenticity_token
  include ApplicationHelper

  # GET /leads
  # GET /leads.json
  def index

    @type = params[:type].blank? ? "Buyer" : params[:type]
    @keyword = params[:search]
    @filter_type = params[:filter_type].blank? ? 'All' : params[:filter_type]
    @leads = filter_leads(@type, @filter_type, @keyword)
    respond_to do |format|
      format.html
      format.json { render json: @leads }
      format.csv { 
        lead_ids = params[:lead_ids]
        leads = Lead.where(:id => lead_ids)
        send_data Lead.where(:id => lead_ids).as_csv
      }
      format.js
    end
  end

  def filter
    @type = params[:type].blank? ? "Buyer" : params[:type]
    @keyword = params[:search]
    @filter_type = params[:filter_type].blank? ? "Buyer" : params[:filter_type]
    @leads = filter_leads(@filter_type, @type, @keyword)
    respond_to do |format|
      format.js
    end
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
    @lead = Lead.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lead }
    end
  end

  # GET /leads/new
  # GET /leads/new.json
  def new
    @lead = Lead.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lead }
    end
  end

  # GET /leads/1/edit
  def edit
    @lead = Lead.find(params[:id])
  end

  # POST /leads
  # POST /leads.json
  def create
    @lead = Lead.new(lead_params)
    respond_to do |format|
      if @lead.save
        LeadsUser.create({:user_id => current_user.id, :lead_id => @lead.id, :source => current_user.id})
        format.html { redirect_to "/leads", notice: 'Lead was successfully created.' }
        format.json { render json: @lead, status: :created, location: @lead }
      else
        format.html { render action: "new" }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end

  end

  # PUT /leads/1
  # PUT /leads/1.json
  def update
    @lead = Lead.find(params[:id])
    saved = @lead.update_attributes(lead_params)

    respond_to do |format|
      if saved
        format.html { redirect_to @lead, notice: 'Lead was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy

    respond_to do |format|
      format.html { redirect_to leads_url }
      format.json { head :ok }
      format.js
    end
  end

  def ajax_update
    attr_name = params["name"]
    attr_name.slice!("_#{params["pk"]}")
    attr_value = params["value"]
    lead = Lead.find(params["pk"])
    json_data = Hash.new
    if attr_name == "suburb_state_postcode"
      lead.suburb = attr_value.split(',')[0].strip
      lead.state = attr_value.split(',')[1].strip
      lead.postcode = attr_value.split(',')[2].strip
    else
      lead.attributes = {attr_name => attr_value}
    end
    respond_to do |format|
      format.json { 
        if lead.save 
          render :json => lead.to_json 
        else
          json_data = {:status => 'error', :msg => lead.errors.full_messages.first}
          render :status => 200, :json => json_data
        end
      }
    end
  end

  def delete_leads
    logger.debug "params: #{params.inspect}"
    lead_ids = params[:lead_ids]
    @on_type = params[:on_type]
    Lead.destroy_all(id: lead_ids ) unless lead_ids.blank?
    @leads = filter_leads(@on_type, nil, nil)
    # @leads = Lead.where("id < 5")
    respond_to do |format|
      format.html { redirect_to "/leads" }
      format.js
    end
    # @leads = user.leads.all
    # respond_to do |format|
    #   format.js
    # end
  end

  def search
    @leads = Lead.all
    respond_to do |format|
      format.js
    end

  end

  def send_bulk_email
    logger.debug "in send_bulk_email..."
    user_id = params[:user_id]
    recipients = params[:recipients]
    subject = params[:subject]
    body = params[:body]
    # Replace AGENCY LOGO
    body.gsub!('[AGENCY LOGO]', "<img src=\"#{current_user.company_logo_url}\" width=\"220px\" height=\"41px\" >")
    # property files
    attached_files = Hash.new
    # uploaded external files
    upload_files = params[:attachments].blank? ? [] : params[:attachments]
    upload_files.each do |file_path|
      file_name = Pathname.new(file_path).basename.to_s
      attached_files[file_name] = Lead.upload_file_url(file_path)
    end

    user = User.find(user_id)
    failed_recipients = []
    recipients_array = recipients.split(',')
    recipients_array.each do |recipient|
      begin
        UserMailer.bulk_email(user.email, subject, recipient, body, attached_files).deliver_now
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        logger.error e.message
        logger.error e.backtrace.join("\n")
        failed_recipients << recipient
      end
    end
    if recipients_array.blank?
      @message = "No recipient has been specified"
      @notification_type = "error"
    else
      if failed_recipients.blank?
        @message = recipients_array.count > 1 ? "#{recipients_array.count} emails have been sent" : "1 email has been sent"
        # @message = "#{recipients_array.count} #{'email'.pluralize(recipients_array.count)} #{'has'.pluralize(recipients_array.count)} been sent"
        @notification_type = "success"
      else
        @message = "Failed to send email to #{failed_recipients.join(', ')}"
        @notification_type = "error"
      end
    end

    respond_to do |format|
      format.html {
        render :nothing => true, :status => :ok
      }
      format.js {
        # @inspection_lead_ids = Array.new
        # inspection = Inspection.find(inspection_id)
        # recipients_array.each do |recipient_email|
        #   lead = inspection.leads.where(:email => recipient_email).first
        #   next if lead.blank?
        #   inspection_lead = InspectionsLead.where(:lead_id => lead.id, :inspection_id => inspection_id).first
        #   next if inspection_lead.blank?
        #   @inspection_lead_ids << inspection_lead.id
        # end
      }
    end

  end

  # Upload files
  def upload_file
    logger.debug "upload_file ..."
    uploaded_io = params[:file]
    file_name = uploaded_io.original_filename 
    file_name = sanitize_filename(file_name)
    dir = Rails.root.join('public', 'uploads', current_user.id.to_s, 'leads')
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    new_dir = nil
    (1..10000).to_a.each do |i|
      new_dir = dir.to_s + "/" + i.to_s
      next if File.exist?(new_dir)
      FileUtils.mkdir_p(new_dir)
      break
    end
    logger.debug "new_dir: #{new_dir}"
    unless new_dir.blank?
      File.open("#{new_dir}/#{file_name}", 'wb') do |file|
        file.write(uploaded_io.read)
      end
    end
    file_path = new_dir + "/" + file_name
    if cookies[:attachments].blank?
      cookies[:attachments] = file_path
    else
      cookies[:attachments] = cookies[:attachments] + "," + file_path
    end
    logger.debug "cookies: #{cookies[:attachments]}"

    respond_to do |format|
      format.json {
        render :nothing => true, :status => 200
      }
    end
  end

  private
  def lead_params
    params.require(:lead).permit(:first_name, :last_name, :telephone, :email, :source)
  end

  def filter_leads(on_type, filter_type, keyword)

    logger.debug "filter_type: #{filter_type}"
    # filter by inspection status (sold or leased)
    if filter_type.blank? or filter_type == 'All'
      logger.debug "no filter type specified"
      # sold_or_leased_inspection_ids = Inspection.all.map{|t| t.id}
      @leads = Lead.joins(:leads_users).joins('LEFT JOIN inspections_leads on inspections_leads.lead_id = leads.id')
        .select("leads.*, inspections_leads.last_follow_up")
        .where("leads_users.on_type = ? AND leads_users.user_id = ?", on_type, current_user.id)
        .uniq.order("inspections_leads.last_follow_up DESC")
    else
      sold_or_leased_inspection_ids = Inspection.where(:status => filter_type).map{|t| t.id}
      logger.debug "sold_or_leased_inspection_ids: #{sold_or_leased_inspection_ids.inspect}"
      @leads = Lead.joins(:leads_users, :inspections_leads)
        .select("leads.*, inspections_leads.last_follow_up")
        .where("leads_users.on_type = ? AND leads_users.user_id = ?", on_type, current_user.id)
        .where("inspections_leads.sold_or_leased = true")
        .uniq.order("inspections_leads.last_follow_up DESC")
        # .where("inspections_leads.inspection_id IN (?)", sold_or_leased_inspection_ids).uniq.order(:first_name)
    end
    # filter duplicate lead as duplicates coming from joining inspections_leads WEB-263
    lead_hash = Hash.new
    @leads.each do |lead|
      if lead_hash.include? lead.id
        lead_in_hash = lead_hash[lead.id]
        if not lead.last_follow_up.blank? and not lead_in_hash.last_follow_up.blank?
          lead_hash[lead.id] = lead if lead.last_follow_up > lead.last_follow_up
        end
      else
        lead_hash[lead.id] = lead
      end
    end
    @leads = lead_hash.values.sort{|a,b| b.last_follow_up.to_s <=> a.last_follow_up.to_s}

    # filter by keyword
    # if not keyword.blank?
    #   # filter by keyword
    #   @leads = current_user.leads.where("first_name like ? or last_name like ? or telephone like ? or email like ?", 
    #     "%#{keyword}%",  "%#{keyword}%",  "%#{keyword}%",  "%#{keyword}%")
    # else
    #   @leads = current_user.leads.all.order(:updated_at)
    # end

    return @leads

  end

end



