class AddTokenUsedToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :used, :boolean
  end

  def self.down
    remove_column :invitations, :used
  end
end
