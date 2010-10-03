class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.string :name
      t.string :email
      t.string :topic
      t.string :message
      t.timestamps
    end
  end
  
  def self.down
    drop_table :emails
  end
end
