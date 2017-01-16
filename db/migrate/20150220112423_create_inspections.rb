class CreateInspections < ActiveRecord::Migration
  def change
    create_table :inspections do |t|
      t.integer :user_id
      t.string :full_address, :comment => 'street address + suburb + state + postcode'
      t.string :street_address
      t.string :state
      t.string :postcode
      t.string :suburb
      t.string :status, :comment => 'For Sale, Sold, Disabled | For Lease, Leased, Disabled'
      t.string :on_type, :comment => 'Sale | Lease'
      t.string :vender_email
      t.string :bedrooms
      t.string :bathrooms
      t.string :parking
      t.string :headline
      t.text :description
      t.string :property_images
      t.string :floor_plates
      t.string :ensuites
      t.string :toilets
      t.string :living_areas
      t.string :house_size
      t.string :land_size
      t.string :energy_efficiency_rating
      t.float :listing_price, :comment => 'From real estate sites'
      t.date :listing_date, :comment => 'From real estate sites'
      t.string :listing_url, :comment => 'From real estate sites'
      t.float :sold_price
      t.date :sold_date
      t.integer :sold_lead_id, :comment => 'Sold to lead'
      t.string :property_type, :comment => 'Unit, Apartment, House ....'
      t.string :sales_type, :comment => 'Auction or Private Treaty ...'
      t.date :date_available, :comment => 'From real estate sites'
      t.string :property_files
      t.integer :count_maybe_like
      t.integer :count_all_registered
      t.integer :count_latest
      t.integer :count_potential_buyers
      t.integer :count_follow_ups
      t.datetime :last_updated, :comment => 'From iPad'
      t.boolean :is_sample
      t.boolean :send_file, :comment => "send property files? inspection wide"
      t.integer :last_follow_up_user_id, :comment => 'Last follow up user/agent id'

      t.timestamps null: false
    end
  end
end
