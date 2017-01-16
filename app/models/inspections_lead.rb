class InspectionsLead < ActiveRecord::Base
  belongs_to :inspection
  belongs_to :lead

  after_initialize :init
  # after_update :post_update_attributes
  before_save :pre_save_attributes
  after_save :post_save_attributes

  validates :inspection_id, :lead_id, presence: true

  def init
    self.last_follow_up ||= Time.zone.now 
    # self.address ||= build_address #let's you set a default association
  end

  # def post_update_attributes
  #   logger.debug "debug ..."
  #   logger.debug "last_follow_up_type_changed?: #{last_follow_up_type_changed?}"
  #   logger.debug "Time.zone.now: #{Time.zone.now.inspect}"
  #   # update last_follow_up accordingly
  #   if last_follow_up_type_changed?
  #     self.last_follow_up = Time.zone.now
  #     self.save
  #   end
  #   logger.debug "self: #{self.inspect}"
  # end

  def pre_save_attributes
    self.last_follow_up = Time.zone.now
    logger.debug "last_follow_up_type_changed?: #{last_follow_up_type_changed?}"
    logger.debug "self.changes: #{self.changes.inspect}"
    if last_follow_up_type_changed? and self.changes[:last_follow_up_type][1] == 'Sold'
      self.sold_or_leased = true
      logger.debug "updated to sold or leased"
    end
    if last_follow_up_type_changed? and self.changes[:last_follow_up_type][1] != 'Sold'
      self.sold_or_leased = false
      # TO FIX: interest BUG, removing the following debug message will sometimes result in saving failure. NEED to investigate.
      logger.debug "updated to NOT sold or leased"
    end
  end

  def post_save_attributes
    logger.debug "post_save_attributes..."
    logger.debug "self.changes: #{self.changes.inspect}"
    if not self.changes[:last_follow_up_type].blank?
      last_follow_up_type = self.changes[:last_follow_up_type][1]
      if last_follow_up_type_changed? and (last_follow_up_type == 'Sold' or last_follow_up_type == 'Leased')
        inspection = Inspection.find(self.inspection_id)
        inspection.status = last_follow_up_type
        inspection.save
      end
    end

  end

  def display_offer_price
    "$#{self.offer_price.to_i}" unless self.offer_price.blank?
  end


end

