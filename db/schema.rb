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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100922181617) do

  create_table "accounts", :force => true do |t|
    t.string   "details"
    t.decimal  "cost",       :precision => 6, :scale => 2
    t.integer  "allotment"
    t.decimal  "accrued",    :precision => 6, :scale => 2
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "daily_stats", :force => true do |t|
    t.date     "day"
    t.decimal  "days_spending", :precision => 6, :scale => 2
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_stats", ["day"], :name => "index_daily_stats_on_day"

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email"
    t.string   "token"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spendings", :force => true do |t|
    t.date     "spending_date"
    t.string   "spending_details"
    t.decimal  "spending_amount",  :precision => 6, :scale => 2
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spendings", ["user_id"], :name => "index_spendings_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",                                            :default => false
    t.decimal  "daily_bank",         :precision => 6, :scale => 2
    t.decimal  "stash",              :precision => 6, :scale => 2
    t.decimal  "spending_balance",   :precision => 6, :scale => 2
    t.integer  "invitation_id"
    t.integer  "invitation_limit"
    t.string   "timezone"
  end

end
