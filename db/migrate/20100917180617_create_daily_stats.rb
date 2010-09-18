class CreateDailyStats < ActiveRecord::Migration
  def self.up
    create_table :daily_stats do |t|
      t.date :day
      t.decimal :days_spending, :precision => 6, :scale => 2
      t.integer :user_id

      t.timestamps
    end
    add_index :daily_stats,:day
  end

  def self.down
    drop_table :daily_stats
  end
end
