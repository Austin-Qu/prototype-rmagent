class CreateLeadsInspectionsJoinTables < ActiveRecord::Migration
  def change
    create_table :inspections_leads do |t|
      t.integer :lead_id
      t.integer :inspection_id
      t.integer :rating
      t.datetime :inspection_datetime
      t.float :offer_price
      t.text :memo
      t.integer :count_inspections
      t.boolean :invited
      t.boolean :maybe_liked
      t.boolean :inspected
      t.boolean :send_file
      t.integer :count_follow_ups
      t.datetime :last_follow_up
      t.string :last_follow_up_type, :comment => "last follow up types: ipad register, from import ,newly added, invited, ipad followup, called, emailed etc. "
      t.integer :follow_up_source_id, :comment => "User/agent"
      t.boolean :sold_or_leased, :comment => "Sold or leased to the lead"

      t.timestamps null: false
    end
  end
end
