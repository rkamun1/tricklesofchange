class ChangeDailystashDaysDateTimeToDate < ActiveRecord::Migration
  def self.up
    change_table :daily_stats do |t|
      t.change :day, :date
    end
  end

  def self.down
  end
end
