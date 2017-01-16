class InspectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]
  skip_before_filter  :verify_authenticity_token
  include ApplicationHelper

  # GET /inspections
  # GET /inspections.json
  def index
    status = params[:status]
    @type = params[:type].blank? ? "Sale" : params[:type]
    @inspections = filter_inspections(status, @type)

    respond_to do |format|
      format.html
      format.js
    end

  end

  def filter
    status = params[:status]
    @type = params[:type].blank? ? "Sale" : params[:type]
    @inspections = filter_inspections(status, @type)
    respond_to do |format|
      format.js
    end
  end

  # GET /inspections/1
  # GET /inspections/1.json
  def show
  end

  # GET /inspections/new
  def new
    @inspection = Inspection.new
  end

  # GET /inspections/1/edit
  def edit
  end

  # POST /inspections
  # POST /inspections.json
  def create
    @inspection = Inspection.new(inspection_params)
    suburb, postcode = params[:inspection][:suburb_and_postcode].split(',')
    @inspection.suburb = suburb.strip
    @inspection.postcode = postcode.strip
    uploaded_io = params[:inspection][:property_images]
    logger.debug "uploaded_io: #{uploaded_io.inspect}"
    filename = uploaded_io.original_filename
    filename = sanitize_filename(filename)
    @inspection.property_images = filename

    respond_to do |format|
      if @inspection.save
        dir = Rails.root.join('public', 'uploads', @inspection.id.to_s)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        File.open("#{dir}/#{filename}", 'wb') do |file|
          file.write(uploaded_io.read)
        end
        format.html { redirect_to "/inspections", notice: 'Inspection was successfully created.' }
        format.json { render :show, status: :created, location: @inspection }
      else
        format.html { render :new }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_default
    status = params[:status]
    @type = params[:type]
    @inspection = Inspection.create_default(@type, current_user.id)
    @inspection.save
    @inspections = filter_inspections(status, @type)

    respond_to do |format|
      format.js
    end
  end

  # PATCH/PUT /inspections/1
  # PATCH/PUT /inspections/1.json
  def update
    respond_to do |format|
      if @inspection.update(inspection_params)
        format.html { redirect_to @inspection, notice: 'Inspection was successfully updated.' }
        format.json { render :show, status: :ok, location: @inspection }
      else
        format.html { render :edit }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inspections/1
  # DELETE /inspections/1.json
  def destroy
    if @inspection.destroy
      # clear uploads folder
      dir = Inspection.upload_file_dir(current_user.id, @inspection.id)
      FileUtils.rm_rf(dir) if File.exists?(dir)
    end

    respond_to do |format|
      format.html { redirect_to inspections_url, notice: 'Inspection was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end

  def ajax_update
    attr_name = params["name"].dup
    attr_name.slice!("_#{params["pk"]}")
    attr_value = params["value"]
    ins = Inspection.find(params["pk"])
    json_data = Hash.new
    saved = nil
    if attr_name == "suburb_state_postcode"
      if not attr_value.blank? and attr_value.split(',').count == 3
        ins.suburb = attr_value.split(',')[0].strip
        ins.state = attr_value.split(',')[1].strip
        ins.postcode = attr_value.split(',')[2].strip
        saved = ins.save
      else
        json_data[params["name"]] = ins.suburb_state_postcode
        json_data['updated?'] = false
      end
    else
      ins.attributes = {attr_name => attr_value}
      saved = ins.save 
    end
    json_data.merge!(ins.attributes)
    respond_to do |format|
      format.json { 
        if saved.nil? 
          render :json => json_data.to_json 
        elsif saved
          render :status => 227, :json => ins
        else
          json_data = {:status => 'error', :msg => ins.errors.full_messages.first}
          render :status => 200, :json => json_data
        end
      }
    end
  end

  # upload image
  def upload
    logger.debug "uploading ..."
    # if not params[:property_images].blank?
    #   name = "property_images"
    # end
    name = "property_images"
    inspection = Inspection.find(params[:inspection_id])
    uploaded_io = params[:file]
    # file_name = uploaded_io.original_filename
    file_name = uploaded_io.original_filename.split('.')[0] 
    file_type = uploaded_io.original_filename.split('.')[1]
    file_name = "#{file_name}_#{current_user.id}_#{inspection.id}.#{file_type}"
    file_name = sanitize_filename(file_name)
    dir = Inspection.upload_file_dir(current_user.id, inspection.id)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open("#{dir}/#{file_name}", 'wb') do |file|
      file.write(uploaded_io.read)
    end
    old_file_name = inspection.property_images
    logger.debug "name: #{name}, file_name: #{file_name}"
    inspection.update_attribute(name, file_name)
    if file_name != old_file_name
      # delete file on disk
      file_path = Inspection.property_file_path(current_user.id, inspection.id, old_file_name)
      File.delete(file_path) if File.exist?(file_path)
    end
    inspection.save
    redirect_to :back
  end

  # Uploaded attachment is now added as property file, saved to property files list
  def upload_attachment
    inspection = Inspection.find(params[:inspection_id])
    upload_io = params[:upload_file]
    @upload_attachment_name = upload_io.original_filename 
    @upload_attachment_name = sanitize_filename(@upload_attachment_name)
    # file_type = uploaded_io.original_filename.split('.')[1]
    # file_name = "#{name}_#{current_user.id}_#{inspection.id}.#{file_type}"
    # TODO make sure uploaded external file doesn't conflict existing files
    dir = Inspection.upload_file_dir(current_user.id, inspection.id)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open("#{dir}/#{@upload_attachment_name}", 'wb') do |file|
      file.write(upload_io.read)
    end
    # add as property file, saved to property files list
    inspection.add_property_file(@upload_attachment_name)
    inspection.save

    respond_to do |format|
      format.html {
        render :nothing => true, :status => 200, :content_type => 'text/html'
      }
      format.js
    end
  end

  def delete_property_file
    @property_file_name = params[:property_file_name]
    @inspection = Inspection.find(params[:inspection_id])
    property_files = @inspection.property_files_to_array
    property_files.delete @property_file_name
    @inspection.property_files = property_files.join(',')
    if @inspection.save
      # delete file on disk
      file_path = Inspection.property_file_path(current_user.id, @inspection.id, @property_file_name)
      File.delete(file_path)
    end

  end

  # Upload files
  def upload_property_file
    logger.debug "upload_property_file ..."
    @inspection = Inspection.find(params[:inspection_id])
    # uploaded_io = params["property_file"]
    uploaded_io = params[:file]
    file_name = uploaded_io.original_filename
    file_name = sanitize_filename(file_name)
    # dir = Rails.root.join('public', 'uploads', @inspection.id.to_s)
    dir = Inspection.upload_file_dir(current_user.id, @inspection.id)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    file_path = "#{dir}/#{file_name}"
    error = nil
    if File.exist?(file_path)
      error = "#{file_name} has been uploaded. Please rename the file and upload it again."
    else
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_io.read)
      end
      # property_files = @inspection.property_files_to_array
      # property_files << file_name
      # @inspection.property_files = property_files.join(',')
      @inspection.add_property_file(file_name)
      @inspection.save
      # redirect_to :back
      # render :status => 400, :error => "ERROR"
    end
    respond_to do |format|
      format.json {
        logger.debug "returning 400, error: #{error}"
        if error
          render :nothing => true, :status => 520
        else
          render :nothing => true, :status => 200
        end
      }
    end
  end

  def get_leads_emails_by_user
    user = User.find(params[:user_id])
    @leads = user.leads
  end

  def send_bulk_email
    logger.debug "in send_bulk_email..."
    template_type = params[:template_type]
    inspection_id = params[:inspection_id]
    inspection = Inspection.find(inspection_id)
    user_id = params[:user_id]
    recipients = params["recipients_#{inspection_id}"]
    subject = params[:subject]
    orig_body = params[:body]
    # property files
    property_files = params[:property_files].blank? ? [] : params[:property_files]
    attached_files = Hash.new
    property_files.each do |property_file|
      next if property_file.blank?
      # attached_files[property_file] = Inspection.property_file_path(current_user.id, inspection_id, property_file)
      attached_files[property_file] = inspection.property_file_url(property_file)
    end
    # uploaded external files
    # upload_files = params[:upload_files].blank? ? [] : params[:upload_files]
    # upload_files.each do |upload_file|
    #   attached_files[upload_file.original_filename] = inspection.property_file_url(upload_file.original_filename)
    # end

    user = User.find(user_id)
    failed_recipients = []
    recipients_array = recipients.split(',')
    recipients_array.each do |recipient|
      lead = inspection.leads.where(:email => recipient).first
      dear_lead_name = lead.blank? ? 'Sir/Madam' : lead.first_name
      body = orig_body.gsub('[ATTENDEE]', dear_lead_name).gsub('[AGENCY LOGO]', "<img src=\"#{current_user.company_logo_url}\" width=\"220px\" height=\"41px\" >")
      begin
        UserMailer.bulk_email(user.email, subject, recipient, body, attached_files).deliver_now
        # Update inspection_lead's last followup type
        # lead = inspection.leads.where(:email => user.email).first
        inspection_lead = InspectionsLead.where(:lead_id => lead.id, :inspection_id => inspection_id).first
        unless inspection_lead.blank?
          inspection_lead.last_follow_up_type = 'Email Sent'
          inspection_lead.save
        end
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
        @inspection_lead_ids = Array.new
        inspection = Inspection.find(inspection_id)
        recipients_array.each do |recipient_email|
          lead = inspection.leads.where(:email => recipient_email).first
          next if lead.blank?
          inspection_lead = InspectionsLead.where(:lead_id => lead.id, :inspection_id => inspection_id).first
          next if inspection_lead.blank?
          @inspection_lead_ids << inspection_lead.id
        end
        # @message = recipients_array.count > 1 ? "#{count} emails have been sent" : "1 email has been sent" 
        # @notification_type = "success"
      }
    end

  end

  def filter_inspection_leads
    logger.debug "in filter_inspection_leads..."
    # Rails.application.config.filter_types = ['All', 'New', 'Rating', 'Followup', 'No Followup', 'Contract', 'Inspection Date'] 
    # All: return all, sorted by time
    # New: return all, sorted by inspection_datetime
    # Rating: return rating > 0, sorted by registry rating, then time
    # Followup: return  'iPad Follow-up', 'Phone Call', 'Email sent', sorted by updated_at
    # No Followup: return ipad reistered, newly added, sorted by time
    # Contract: return 'Under contract', sorted by updated_at
    # 

    @on_type = params[:on_type]
    filter_type = params[:filter_type].blank? ? nil : params[:filter_type].downcase
    filter_date = params[:filter_date]
    if filter_date.blank?
      filter_datetime = nil
    else
      filter_datetime = Date.strptime(params[:filter_date],"%Y-%m-%d")
      filter_date_end = (filter_datetime + 1.day).strftime("%Y-%m-%d")
    end
    @inspection = Inspection.find(params[:inspection_id])
    if filter_type == 'all'
      @inspections_leads = @inspection.inspections_leads.order(last_follow_up: :desc)
    elsif filter_type == 'new'
      # WEB-120
      @inspections_leads = Array.new
      unless @inspection.inspections_leads.blank?
        last_inspection_lead = @inspection.inspections_leads.order(:inspection_datetime).last
        last_inspection_datetime = last_inspection_lead.inspection_datetime
        logger.debug ">>>>last_inspection_datetime: #{last_inspection_datetime.inspect}"
        @inspections_leads = @inspection.inspections_leads
          .where(inspection_datetime: (last_inspection_datetime.beginning_of_day..last_inspection_datetime.end_of_day))
          .order(last_follow_up: :desc)
      end
    elsif filter_type == 'rating'
      @inspections_leads = @inspection.inspections_leads.where("rating > 0").order(rating: :desc) #, :last_follow_up)
    elsif filter_type == 'follow-up'
      @inspections_leads = @inspection.inspections_leads.where(:last_follow_up_type => Rails.application.config.is_followed_up_types).order(last_follow_up: :desc)
    elsif filter_type == 'no follow-up'
      @inspections_leads = @inspection.inspections_leads.where(:last_follow_up_type => ['iPad registered', 'Newly added']).order(last_follow_up: :desc)
    elsif filter_type == 'sold' or filter_type == 'leased'
      @inspections_leads = @inspection.inspections_leads.where(:last_follow_up_type => filter_type.capitalize).order(last_follow_up: :desc)
    #WEB-77 remove the inspection date 
    #elsif filter_type == 'inspection date'
    #  if filter_datetime.blank?
    #    @inspections_leads = @inspection.inspections_leads.order(:created_at)
    #  else
    #    @inspections_leads = @inspection.inspections_leads.where(:inspection_datetime => filter_date..filter_date_end).order(:created_at)
    #  end
    end

    respond_to do |format|
      format.js
    end
  end

  def inspection_sold
    inspection_lead_id = params[:inspection_lead_id]
    if inspection_lead_id.blank?
      @inspection = Inspection.find(params[:inspection_id])
      # Lead full name
      lead_name = params[:lead]
      # TODO find lead here
    else
      @inspection_lead = InspectionsLead.find(inspection_lead_id)
      @inspection = @inspection_lead.inspection
      lead = @inspection_lead.lead
    end
    sold_price = params[:sold_price]
    @inspection.sold_price = sold_price
    @inspection.sold_lead_id = lead.id unless lead.blank?
    @inspection.status = 'Sold'
    @inspection.last_updated = Time.zone.now
    @inspection_lead.last_follow_up = Time.zone.now unless @inspection_lead.blank?
    respond_to do |format|
      if @inspection.save
        @inspection_lead.save
        format.js 
      end
    end    
  end

  def render_inspection
    inspection_id = params[:inspection_id]
    @on_type = params[:on_type]
    @selected_inspection_lead_ids = params[:selected_inspection_lead_ids]
    logger.debug "@on_type is: #{@on_type}, @selected_inspection_lead_ids: #{@selected_inspection_lead_ids}"
    @inspection = Inspection.find(inspection_id)
    respond_to do |format|

      logger.debug "responding"
      format.js {
        logger.debug "in format.js"
      }
    end    

  end

  def render_panel_heading
    @on_type = params[:on_type]
    respond_to do |format|
      format.js
    end    

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inspection
      @inspection = Inspection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inspection_params
      params.require(:inspection).permit(:street_address, :property_type, :bedroom, :bathroom, :parking, :price, :sales_type, :property_date, 
        :floor_area, :land_area, :description, :listing_url, :status, :property_files, :user_id, :property_images, :on_type)
    end

    def order_inspections(inspections, sale_type)
      if sale_type == "Sale"
        inspections_for_sale = inspections.where(:status=>"For Sale").order(updated_at: :desc)
        inspections_sold = inspections.where(:status=>"Sold").order(updated_at: :desc)
        inspections_disabled = inspections.where(:status=>"Disabled").order(updated_at: :desc)
        return inspections_for_sale + inspections_sold + inspections_disabled
      else
        # Lease
        inspections_for_lease = inspections.where(:status=>"For Lease").order(updated_at: :desc)
        inspections_leased = inspections.where(:status=>"Leased").order(updated_at: :desc)
        inspections_disabled = inspections.where(:status=>"Disabled").order(updated_at: :desc)
        return inspections_for_lease + inspections_leased + inspections_disabled
      end
    end

    def filter_inspections(status, on_type)
      if status.blank? or status == 'All'
        inspections = current_user.inspections.where(:on_type => on_type).order(updated_at: :desc)
      else
        inspections = current_user.inspections.where(:status => status, :on_type => on_type).order(updated_at: :desc)
      end
      inspections = order_inspections(inspections, on_type)
    end

end
