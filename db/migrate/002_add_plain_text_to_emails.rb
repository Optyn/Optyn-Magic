class AddPlainTextToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :plain_message, :text
    rename_column :emails, :content, :html_message
  end
end
