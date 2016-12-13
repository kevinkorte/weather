class AddAlertsToTable < ActiveRecord::Migration
  def change
    add_column :conditions, :alert_message, :string
    add_column :conditions, :alert_start_date, :string
    add_column :conditions, :alert_expire_date, :string
  end
end
