class MessagesController < ApplicationController
  include MessagesHelper

  def index
  end

  def activation_code
    code = send_activation_code('111')
    session[:activation_code] = code unless code.blank?
    respond_to do |format|
      format.html { render :nothing => true, :status => 200, :content_type => 'text/html' }
      format.json { render json: {"code" => code} }
    end
    
  end

  def contact_form
    logger.debug "email..."
    logger.debug params.inspect

    @email_sent_message = ''
    begin
      UserMailer.contact_form(params).deliver_now
      message = I18n.t 'message.message_sent_success'
      error_type = I18n.t 'message.success'
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
      message = I18n.t 'message.message_sent_fail'
      error_type = I18n.t 'message.error'
    end

    # render :nothing => true
    respond_to do |format|
      format.html { render :nothing => true, :status => 200, :content_type => 'text/html' }
      format.json { 
        render json: {
          "error_type" => error_type, 
          "message" => message
        }
      }
    end

  end
end
