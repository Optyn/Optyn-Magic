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
    Email.where(sent: false).each { |email|
      is_sent = ApiCalls.instance.create_message(email.from, email.to, email.content, email.subject)
      email.update_attribute(:sent,  is_sent)
      puts "====================="
      puts "Time #{Time.now}"
      puts "Email: #{email.id} was sent: #{is_sent}"
    }
  end
end


