class AddMaturityDateToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :maturity_date, :date
  end

  def self.down
    remove_column :accounts, :maturity_date
  end
end
