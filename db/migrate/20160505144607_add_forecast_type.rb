class AddForecastType < ActiveRecord::Migration
  def change
  	add_column :conditions, :forecast, :string
  end
end
