class AddSendBoolToConditions < ActiveRecord::Migration
  def change
  	add_column :conditions, :sent, :string
  end
end
