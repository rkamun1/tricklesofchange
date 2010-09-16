class AddDailyBalanceToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :daily_balance, :decimal, :precision => 6, :scale => 2
  end

  def self.down
    remove_column :users, :daily_balance
  end
end
