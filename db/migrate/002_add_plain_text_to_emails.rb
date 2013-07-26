class CreateEmails < ActiveRecord::Migration
  def change
    add_column :emails, :plain_message
    rename_column :emails, :content, :html_message
  end
end
