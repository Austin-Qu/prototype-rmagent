class LeadsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :lead

  validates :user_id, :lead_id, :source, :on_type, presence: true
end

