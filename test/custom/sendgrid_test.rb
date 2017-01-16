# using SendGrid's Ruby Library - https://github.com/sendgrid/sendgrid-ruby
require 'sendgrid-ruby'

api_user = "realtymate"
api_key = "realtymate2015"
client = SendGrid::Client.new(api_user: api_user, api_key: api_key)

email = SendGrid::Mail.new do |m|
  m.to      = 'xwmeng@gmail.com'
  m.to_name      = 'aXiangwei aMeng'
  m.from    = 'info@realtymate.com.au'
  m.subject = 'Sending with SendGrid is Fun'
  m.html    = 'and easy to do anywhere, even with Ruby'
end
#email.add_attachment('/tmp/a.txt')
#email.add_attachment('/tmp/x-editable-master.zip')

result = client.send(email)
puts result.inspect