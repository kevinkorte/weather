class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.string :weather
      t.text :wind_string
      t.string :wind_dir
      t.string :wind_mph
      t.string :wind_gust_mph
      t.string :temp_f
      t.string :feelslike_f
      t.text :precip_today_in
      t.text :icon_url
      t.text :observation_time

      t.timestamps null: false
    end
  end
end
