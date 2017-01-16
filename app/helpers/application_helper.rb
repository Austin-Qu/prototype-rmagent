module ApplicationHelper
  # Capitalize first letter only even in sentence
  def capitalize_first_letter(text)
    unless text.blank?
      text.split.map(&:capitalize).join(' ')
    else
      text
    end
  end

  def followup_icon(followup_type)
  	logger.debug "icon #{followup_type}"
  	case followup_type.to_s.downcase
  	when "phone call"
  	  return "fa fa-lg fa-phone" 
  	when "newly registered"
  	  return "fa fa-lg fa-tablet"
  	when "ipad follow-up"
  	  return "fa fa-lg fa-check"
  	when "email sent"
  	  return "fa fa-lg fa-envelope-o"
  	when "email requested"
  	  return "fa fa-lg fa-files-o"
  	when "sold"
  	  return "fa fa-lg fa-key"
  	when "newly added"
  	  return "fa fa-lg fa-user-plus"
  	else
  	  return "fa fa-lg fa-user-plus"
  	end
  end

  def display_date(datetime)
    # e.g. Fri, 1 Jan 2010
    datetime.strftime('%a, %d %b %Y')
  end 

  # http://guides.rubyonrails.org/security.html#file-uploads
  def sanitize_filename(filename)
    filename.strip.tap do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.sub! /\A.*(\\|\/)/, ''
      # Finally, replace all non alphanumeric, underscore
      # or periods with underscore
      name.gsub! /[^\w\.\-]/, '_'
    end
  end

end
