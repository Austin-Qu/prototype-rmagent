Rails.application.config.email_setting_file_send_subject = "%s"
# Rails.application.config.email_setting_file_send_body = "Dear "
Rails.application.config.email_setting_file_send_body = "Dear Sir/Madam,\nThanks you for your interest in %s.\nAs requested, please find attached the copy of the property contract. \nPlease do not hesitate to contact me should you have any questions regarding this property or the contract.\n\nYours sincerely\n%s\n%s\nPh %s\nFax %s\nMob %s\nWebsite %s"

Rails.application.config.email_setting_file_send_body1 = 
"Dear Sir/Madam,
  
Thanks you for your interest in %s.

As requested, please find attached the copy of the property contract.

Please do not hesitate to contact me should you have any questions regarding this property or the contract.


Yours sincerely

%s
%s
Ph %s
Fax %s
Mob %s
Website %s"

Rails.application.config.email_setting_invitation_subject = 'Invitation Subject'
Rails.application.config.email_setting_invitation_body = 'Invitation Body'
Rails.application.config.email_setting_sold_or_lease_alert_subject = 'Sold or lease alert Subject'
Rails.application.config.email_setting_sold_or_lease_alert_body = 'Sold or lease alert Body'

Rails.application.config.email_setting_select_types = ['File Send', 'Invitation', 'Sold or leased alert']


Rails.application.config.email_setting_fs_subject = "[ADDRESS]"
Rails.application.config.email_setting_fs_body = "
Dear [ATTENDEE],

Thank you for your interest in [ADDRESS]. 
See [LISTING_WEBSITE].

As requested, please find the attached property files.

Please do not hesitate to contact me should you have any questions regarding this property.

Yours sincerely,

[AGENCY LOGO]

[AGENT NAME]
Email: [AGENT EMAIL]
Mobile: [AGENT MOBILE]
[AGENT COMPANY]

————————————————————-

Email sent via Realtymate.com.au
"

Rails.application.config.email_setting_bulk_email_signature =
"
Dear [ATTENDEE],





Yours sincerely,

[AGENCY LOGO]

[AGENT NAME]
Email: [AGENT EMAIL]
Mobile: [AGENT MOBILE]
[AGENT COMPANY]

————————————————————

Email sent via Realtymate.com.au

"

Rails.application.config.lead_email_setting_bulk_email_signature =
"
Dear,





Yours sincerely,

[AGENCY LOGO]

[AGENT NAME]
Email: [AGENT EMAIL]
Mobile: [AGENT MOBILE]
[AGENT COMPANY]

————————————————————

Email sent via Realtymate.com.au

"