class AddCurrencyUnitToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :unit, :string
  end

  def self.down
    remove_column :users, :unit
  end
end