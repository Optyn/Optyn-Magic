class AddGoneToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :gone, :boolean
  end
end