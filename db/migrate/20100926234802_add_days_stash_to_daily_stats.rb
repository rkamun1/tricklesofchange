class AddDaysStashToDailyStats < ActiveRecord::Migration
  def self.up
    add_column :daily_stats, :days_stash, :decimal, :precision => 6, :scale => 2
  end

  def self.down
    remove_column :daily_stats, :days_stash
  end
end
