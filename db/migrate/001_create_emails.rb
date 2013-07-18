class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.text :content
      t.string :from
      t.string :to
      t.string :subject
      t.boolean :sent, default: false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
