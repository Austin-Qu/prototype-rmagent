class EmailTemplate < ActiveRecord::Base
  belongs_to :inspection
  belongs_to :user

  def property_files_to_array
    if self.property_files.blank?
      return Array.new
    else
      return self.property_files.split(',')
    end
  end

end
