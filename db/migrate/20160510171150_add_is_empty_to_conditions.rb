class AddIsEmptyToConditions < ActiveRecord::Migration
  def change
  	add_column :conditions, :isEmpty, :string
  end
end
