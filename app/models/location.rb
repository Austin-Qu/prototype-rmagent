class Location < ActiveRecord::Base
  def value
    "#{self.suburb.titleize}, #{self.state.upcase}, #{self.postcode}"
  end

end
