require 'rubygems'
require 'mail'
gem 'activerecord'
require 'active_record'
require 'yaml'


project_root = File.dirname(File.absolute_path(__FILE__))  + '/../'
Dir.glob(project_root + "app/models/*.rb").each { |f| require f }

connection_details = YAML::load(File.open(project_root + 'config/database.yml'))
ActiveRecord::Base.establish_connection(connection_details)

class EmailProcessor
  @queue = :email_processor

  def self.perform(content)
    mail = Mail.read_from_string(content.gsub('X-Original-To', 'To'))
    if mail.multipart?
      html_part = mail.parts.select { |p| p.content_type =~ /text\/html/ }.first
      plain_part ||= mail.parts.select { |p| p.content_type =~ /text\/plain/ }.first
    end
    html_part ||= mail.try(:body).try(:decoded)
    Email.create(html_message: html_part.try(:body).try(:decoded), plain_message: plain_part.try(:body).try(:decoded), from: mail.from.try(:first), to: mail.to.try(:first), subject: mail.subject)
  end
end