class AddTermsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :terms, :bool
  end

  def self.down
    remove_column :users, :terms
  end
end
