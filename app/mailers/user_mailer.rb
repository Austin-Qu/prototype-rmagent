class UserMailer < ApplicationMailer
  default from: 'info@realtymate.com.au'
  default to: 'info@realtymate.com.au'

  api_user = Rails.configuration.action_mailer.smtp_settings[:user_name]
  api_key = Rails.configuration.action_mailer.smtp_settings[:password]
  @@client = SendGrid::Client.new(api_user: api_user, api_key: api_key)
  # http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-callbacks
  # email_with_name = %("#{@user.name}" <#{@user.email}>)
  # mail(to: email_with_name, subject: 'Welcome to My Awesome Site')

  def welcome_email(user)
    @user = user
    @url = 'http://www.realtymate.com.au'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def contact_form(data)
    logger.debug "data: #{data.inspect}"
    @data = data
    subject = 'User Feedback'
    mail(subject: subject)
    # mail = SendGrid::Mail.new do |m|
    #   m.to      = 'info@realtymate.com.au'
    #   m.to_name = 'RealtyMate'
    #   m.from    = 'info@realtymate.com.au'
    #   m.subject = subject
    #   m.text = 'test'
    # end

    # sent = @@client.send(mail)
    # sendgrid_send(mail)

  end

  def apply(data)
    @data = data
    @apply_uri = apply_uri(@data)

    email = email_wtih_name(data[:email], data[:first_name], data[:last_name])
    mail(from: "RealtyMate <info@realtymate.com.au>", to: email, subject: "Apply for RealtyMate Inspection Tool Account")
  end

  def _bulk_email(from, subject, recipient_email, body, attached_files)
    logger.debug "in bulk_email..."
    @body = body
    attached_files.each do |name, path|
      attachments[name] = File.read(path)
    end
    # email with name
    lead = Lead.where(:email => recipient_email).first
    to_email = lead.blank? ? recipient_email : email_wtih_name(lead.email, lead.first_name, lead.last_name)
    logger.debug "before mail"
    mail_sent = mail(from: from, to: to_email, subject: subject, attachments: attachments)

  end

  def bulk_email(from, subject, recipient_email, body, attached_files)
    logger.debug ">> in bulk_email..."
    @body = body.gsub(/(\n|\r\n)/, '<br/>')
    logger.debug ">>>> @body: #{@body}"
    @attached_files_html = ""
    unless attached_files.blank?
      @attached_files_html = ""
      @attached_files_html += "<strong>Attachments:</strong><br/><br/>"
      attached_files.each do |name, url|
        @attached_files_html += "<div style='width:150px; height:150px; display: inline-block; margin-right:15px;margin-bottom: 15px;background-color: #eee;padding-bottom: 10px; border: 1px solid #cccccc;'><div style='width: 130px;height: 110px;word-wrap: break-word;margin-left: 10px;margin-top: 5px;color: #124fcf;font-size:16px;padding-top:15px;'><a href='#{url}' style='text-decoration: none;'><span>#{name}</span></a></div><div style='width: 130px;margin-left: 10px;margin-right: 10px;background-color: #124fcf;text-align: center;padding-top: 4px;padding-bottom: 4px;'><a style='color:#ffffff;text-decoration: none;width: 100%;height: 100%;display: block;' href='#{url}'>Download</a></div></div>"
      end
    end
    # email with name
    lead = Lead.where(:email => recipient_email).first
    to_email = lead.blank? ? recipient_email : email_wtih_name(recipient_email, lead.first_name, lead.last_name)
    logger.debug ">>>> send to: #{to_email}"
    mail_sent = mail(from: from, to: to_email, subject: subject, attachments: attachments)
    logger.debug "after mail mail_sent: #{mail_sent.inspect}"

    # mail = SendGrid::Mail.new do |m|
    #   m.to        = recipient_email
    #   m.to name   = lead.name
    #   m.from      = from
    #   m.subject   = subject
    #   m.text      = body
    # end

    # mail.add_attachment('/tmp/x-editable-master.zip')
    # sent = @@client.send(mail)
    # logger.debug "mail sent: #{sent.inspect}"
  end

  def request_invite(data)
    @data = data
    @apply_uri = apply_uri(@data)
    mail(from: "RealtyMate <info@realtymate.com.au>", to: "RealtyMate <info@realtymate.com.au>", subject: "Invite Request")
  end

  private
  def email_wtih_name(email, first_name, last_name)
    if first_name.blank?
      return email
    else
      if last_name.blank?
        return %("#{first_name}" <#{email}>)
      else
        return %("#{first_name} #{last_name}" <#{email}>)
      end
    end
  end

  def email_sent_mesage(sent)
    # "{\"message\":\"success\"}"
    # {"message": "error", "errors": ["Parameters to and toname should be the same length"]}
    message = nil
    message = sent['errors'].first if sent['message'] != 'success'
  end

  def sendgrid_send(mail)
    message = ''
    begin
      sent = @@client.send(mail)
    rescue SendGrid::Exception => e
      logger.error "SendGrid::Exception occurred"
      logger.error e
      logger.error JSON.parse(e.message)
      message = JSON.parse(e.message)['errors'].first
    end
    return message
  end

  def apply_uri(data)
    # {"utf8"=>"✓", "authenticity_token"=>"tr5pTKoD8TyCLhSHIRYBU1fEKpAUeivEnIi1slO6j4mNt4elDftyMvG+Ikv/OD7r0xF4fGxG1/1cHtkdW2bx+Q==", 
    #  "email"=>"xwmeng@gmail.com", "title"=>"Principal", "first_name"=>"Xiangwei", "last_name"=>"Meng", "business_name"=>"MIMIMAO", "acn"=>["123444"], 
    #  "postcode"=>"2155", "agreed"=>"on", "commit"=>"Apply Now"}
    "#{Rails.application.config.action_controller.default_url_options[:host]}/users/sign_up?email=#{data["email"]}&title=#{data["title"]}&first_name=#{data["first_name"]}&last_name=#{data["last_name"]}&business_name=#{data["business_name"]}&mobile=#{data["mobile"]}&verification_code=#{data["verification_code"]}"
  end

end
