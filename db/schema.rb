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

ActiveRecord::Schema.define(version: 20160510171150) do

  create_table "conditions", force: :cascade do |t|
    t.string   "weather"
    t.text     "wind_string"
    t.string   "wind_dir"
    t.string   "wind_mph"
    t.string   "wind_gust_mph"
    t.string   "temp_f"
    t.string   "feelslike_f"
    t.text     "precip_today_in"
    t.text     "icon_url"
    t.text     "observation_time"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "sent"
    t.string   "forecast"
    t.string   "day_marker"
    t.string   "isEmpty"
  end

end
