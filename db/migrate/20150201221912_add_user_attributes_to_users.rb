class AddUserAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :business_name, :string
    add_column :users, :title, :string
    add_column :users, :mobile, :string
    add_column :users, :enabled, :boolean
    add_column :users, :device_id, :string
    add_column :users, :device_name, :string
    add_column :users, :account_type, :string
    add_column :users, :account_id, :string
    add_column :users, :enterprise_account_id, :string
    add_column :users, :abn, :string
    add_column :users, :acn, :string
    add_column :users, :website, :string
    add_column :users, :profile_picture, :string
    add_column :users, :company_logo, :string
    add_column :users, :telephone, :string
    add_column :users, :fax, :string
    add_column :users, :address, :string
    add_column :users, :suburb, :string
    add_column :users, :state, :string
    add_column :users, :postcode, :string
    add_column :users, :country, :string
    add_column :users, :introduction, :text
  end
end
