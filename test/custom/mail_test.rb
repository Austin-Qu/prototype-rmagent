require 'mail'
Mail.defaults do
  delivery_method :smtp, {
    :address              => "smtp.sendgrid.net",
    :port                 => 587,
    :domain               => "realtymate.com.au",
    :user_name            => 'realtymate',
    :password             => 'realtymate2015',
    :authentication       => "plain",
    :enable_starttls_auto => true
  }
end

mail = Mail.deliver do
  #to 'xwmeng@gmail.com'
  to 'xmeng@weatherzone.com.au'
  from 'xwmeng@gmail.com'
  subject 'This is the subject of your email'
  #attachment File.read('/tmp/a.txt')
  text_part do
    body 'Hello world in text'
  end
  html_part do
    content_type 'text/html; charset=UTF-8'
    body '<b>Hello world in HTML</b>'
  end
end

puts mail
