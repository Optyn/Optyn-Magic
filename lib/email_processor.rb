require 'rubygems'
require 'mail'
gem 'activerecord'
require 'active_record'
require 'yaml'
require 'api_calls'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + "/../app/models/*.rb").each { |f| require f }

connection_details = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(connection_details)

class EmailProcessor
  @queue = :email_processor

  def self.perform(content)
    mail = Mail.read_from_string(content.gsub('X-Original-To', 'To'))
    email = Email.create(content: mail.body.decoded, from: mail.from.try(:first), to: mail.to.try(:first), subject: mail.subject)
    is_sent = ApiCalls.instance.create_message(email.from, email.to, email.content, email.subject)
    email.update_attribute(:sent => is_sent)
  end
end