class AddUserEmailAndUserIdToEmail < ActiveRecord::Migration
  def self.up
    add_column :emails, :user_id, :integer
    add_column :emails, :email, :string
  end

  def self.down
    remove_column :emails, :email
    remove_column :emails, :user_id
  end
end
