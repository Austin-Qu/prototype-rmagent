class EmailTemplatesController < ApplicationController

  # GET /email_templates
  # GET /email_templates.json
  def index

  end

  # GET /email_templates/1
  # GET /email_templates/1.json
  def show
  end

  # GET /email_templates/new
  def new
    @email_template = EmailTemplate.new
  end

  # GET /email_templates/1/edit
  def edit
  end

  # POST /email_templates
  # POST /email_templates.json
  def create
  end

  # PATCH/PUT /email_templates/1
  # PATCH/PUT /email_templates/1.json
  def update
  end

  # DELETE /email_templates/1
  # DELETE /email_templates/1.json
  def destroy
    @email_template.destroy
    respond_to do |format|
      format.html { redirect_to email_templates_url, notice: 'EmailTemplate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def ipad_email_setting
    logger.debug "in ipad_email_setting()..."
    auto_send = params[:auto_send].blank? ? false : params[:auto_send]
    logger.debug "auto_send: #{auto_send}"
    user_id = params[:user_id]
    @inspection_id = params[:inspection_id]
    template_type = params[:template_type]
    property_files = params[:property_files]
    @email_template = EmailTemplate.where(:user_id => user_id, :inspection_id =>  @inspection_id, :template_type => template_type).first
    @email_template = EmailTemplate.new if @email_template.blank?
    @email_template.template_type = template_type
    @email_template.inspection_id =  @inspection_id
    @email_template.user_id = user_id
    @email_template.subject = params[:subject]
    @email_template.body = params[:body]
    # @email_template.property_files = property_files.join(',') unless property_files.blank?
    @email_template.property_files = property_files.nil? ? nil : property_files.join(',')
    logger.debug "before saving"
    respond_to do |format|
      if @email_template.save
        logger.debug 'saved..'
        # Set send_file flag
        inspection = Inspection.find( @inspection_id)
        logger.debug "inspection: #{inspection.inspect}"
        inspection.send_file = auto_send
        inspection.save
        @message = I18n.t 'message.message_ipad_setting_success'
        @save_status = I18n.t 'message.success'
        logger.debug @message
        format.js 
      else
        @message = I18n.t 'message.message_ipad_setting_fail'
        @save_status = I18n.t 'message.fail'
        logger.debug @message
        format.js 
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def email_template_params
      params.require(:email_template).permit(:template_type, :inspection_id, :property_files, :subject, :body, :user_id)
    end

end
