class AddDayMarker < ActiveRecord::Migration
  def change
  	add_column :conditions, :day_marker, :string
  end
end
