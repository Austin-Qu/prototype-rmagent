# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    UserMailer.welcome_email(User.second)
  end

  def contact_form
    data = {
      "user_name" => 'dummy user',
      "user_email" => 'dummy@example.com',
      "message" => 'This is dummy message'
    }
    UserMailer.contact_form(data)
  end

  def apply
    # data = Hash.new
    data = {"utf8"=>"✓", "authenticity_token"=>"tr5pTKoD8TyCLhSHIRYBU1fEKpAUeivEnIi1slO6j4mNt4elDftyMvG+Ikv/OD7r0xF4fGxG1/1cHtkdW2bx+Q==", 
     "email"=>"xwmeng@gmail.com", "title"=>"Principal", "first_name"=>"Xiangwei", "last_name"=>"Meng", "business_name"=>"MIMIMAO", "acn"=>["123444"], 
     "postcode"=>"2155", "agreed"=>"on", "commit"=>"Apply Now", "verification_code"=>"wff1e3", "mobile"=>"1234432123"} 
    UserMailer.apply(data)
  end

  def bulk_email
    from = 'from@example.com'
    subject = '[DUMMY]Property Contract on 6 Knight Street'
    # recipients = 'xwmeng@gmail.com,betty@yuan.com'
    recipient = 'to@example.com'
    body = Rails.application.config.email_setting_fs_body
    attached_files = Array.new
    attached_files << "http://google.com"
    UserMailer.bulk_email(from, subject, recipient, body, attached_files)
  end

end
