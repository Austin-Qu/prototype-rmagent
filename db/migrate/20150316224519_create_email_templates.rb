class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :template_type, :comment => "File Send, Invitation, Sold or leased Alert"
      t.integer :inspection_id
      t.integer :user_id
      t.string :property_files
      t.string :subject
      t.string :body

      t.timestamps null: false
    end
  end
end
