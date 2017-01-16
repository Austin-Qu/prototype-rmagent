class CreateJoinTableUserLead < ActiveRecord::Migration
  def change
    create_table :leads_users do |t|
      t.integer :lead_id
      t.integer :user_id
      t.integer :source, :comment => "coming from user/agent id"
      t.string :on_type, :comment => 'Buyer | Renter'

      t.timestamps null: false
    end
  end
end

