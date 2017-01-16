# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150415234444) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "email_templates", force: :cascade do |t|
    t.string   "template_type",               comment: "File Send, Invitation, Sold or leased Alert"
    t.integer  "inspection_id"
    t.integer  "user_id"
    t.string   "property_files"
    t.string   "subject"
    t.string   "body"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "inspections", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "full_address",                          comment: "street address + suburb + state + postcode"
    t.string   "street_address"
    t.string   "state"
    t.string   "postcode"
    t.string   "suburb"
    t.string   "status",                                comment: "For Sale, Sold, Disabled | For Lease, Leased, Disabled"
    t.string   "on_type",                               comment: "Sale | Lease"
    t.string   "vender_email"
    t.string   "bedrooms"
    t.string   "bathrooms"
    t.string   "parking"
    t.string   "headline"
    t.text     "description"
    t.string   "property_images"
    t.string   "floor_plates"
    t.string   "ensuites"
    t.string   "toilets"
    t.string   "living_areas"
    t.string   "house_size"
    t.string   "land_size"
    t.string   "energy_efficiency_rating"
    t.float    "listing_price",                         comment: "From real estate sites"
    t.date     "listing_date",                          comment: "From real estate sites"
    t.string   "listing_url",                           comment: "From real estate sites"
    t.float    "sold_price"
    t.date     "sold_date"
    t.integer  "sold_lead_id",                          comment: "Sold to lead"
    t.string   "property_type",                         comment: "Unit, Apartment, House ...."
    t.string   "sales_type",                            comment: "Auction or Private Treaty ..."
    t.date     "date_available",                        comment: "From real estate sites"
    t.string   "property_files"
    t.integer  "count_maybe_like"
    t.integer  "count_all_registered"
    t.integer  "count_latest"
    t.integer  "count_potential_buyers"
    t.integer  "count_follow_ups"
    t.datetime "last_updated",                          comment: "From iPad"
    t.boolean  "is_sample"
    t.boolean  "send_file",                             comment: "send property files? inspection wide"
    t.integer  "last_follow_up_user_id",                comment: "Last follow up user/agent id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "inspections_leads", force: :cascade do |t|
    t.integer  "lead_id"
    t.integer  "inspection_id"
    t.integer  "rating"
    t.datetime "inspection_datetime"
    t.float    "offer_price"
    t.text     "memo"
    t.integer  "count_inspections"
    t.boolean  "invited"
    t.boolean  "maybe_liked"
    t.boolean  "inspected"
    t.boolean  "send_file"
    t.integer  "count_follow_ups"
    t.datetime "last_follow_up"
    t.string   "last_follow_up_type",              comment: "last follow up types: ipad register, from import ,newly added, invited, ipad followup, called, emailed etc. "
    t.integer  "follow_up_source_id",              comment: "User/agent"
    t.boolean  "sold_or_leased",                   comment: "Sold or leased to the lead"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "leads", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "telephone"
    t.string   "email"
    t.string   "icon"
    t.string   "sex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leads_users", force: :cascade do |t|
    t.integer  "lead_id"
    t.integer  "user_id"
    t.integer  "source",                  comment: "coming from user/agent id"
    t.string   "on_type",                 comment: "Buyer | Renter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "suburb"
    t.string   "state"
    t.string   "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "business_name"
    t.string   "title"
    t.string   "mobile"
    t.boolean  "enabled"
    t.string   "device_id"
    t.string   "device_name"
    t.string   "account_type"
    t.string   "account_id"
    t.string   "enterprise_account_id"
    t.string   "abn"
    t.string   "acn"
    t.string   "website"
    t.string   "profile_picture"
    t.string   "company_logo"
    t.string   "telephone"
    t.string   "fax"
    t.string   "address"
    t.string   "suburb"
    t.string   "state"
    t.string   "postcode"
    t.string   "country"
    t.text     "introduction"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
