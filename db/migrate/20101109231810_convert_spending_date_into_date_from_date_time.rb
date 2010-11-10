class ConvertSpendingDateIntoDateFromDateTime < ActiveRecord::Migration
  def self.up
    change_table :spendings do |t|
      t.change :spending_date, :date
    end
  end

  def self.down
  end
end
