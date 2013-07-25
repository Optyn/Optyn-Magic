# encoding: UTF-8
require 'rubygems'
require 'redis'
require 'resque'

class MailReceiver
  @queue = :email_replies
  def initialize(content)
    Resque.enqueue(EmailProcessor, content)
  end


end

class EmailProcessor
  @queue = :email_processor
end

MailReceiver.new($stdin.read.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => ''))
