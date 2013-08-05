require 'rubygems'
gem 'activerecord'
require 'active_record'
require 'yaml'
require_relative '../api_calls'

project_root = File.dirname(File.absolute_path(__FILE__)) + '/../../'
Dir.glob(project_root + "app/models/*.rb").each { |f| require f }

connection_details = YAML::load(File.open(project_root + 'config/database.yml'))
ActiveRecord::Base.establish_connection(connection_details)

namespace :messages do
  desc "Make Api call to remote server"
  task :create do
    emails = Email.where("emails.sent = false AND (emails.gone IS NULL OR emails.gone = false)") 
    emails.each { |email|
      puts "====================="
      puts "Time #{Time.now}"
      is_sent, is_gone = ApiCalls.instance.create_message(email.from, email.to, email.html_message, email.subject)
      email.update_attributes(sent: is_sent, gone: is_gone)
      puts "Email: #{email.id} was sent: #{is_sent}. Email is gone? #{is_gone}"
    }
  end
end


