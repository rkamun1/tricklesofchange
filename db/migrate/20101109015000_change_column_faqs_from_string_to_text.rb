class ChangeColumnFaqsFromStringToText < ActiveRecord::Migration
  def self.up
    change_table :faqs do |t|
      t.change :answer, :text
    end
  end

  def self.down
  end
end
