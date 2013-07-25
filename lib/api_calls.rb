require 'rubygems'
require 'json'
require 'oauth2'
require 'openssl'
require 'httparty'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class ApiCalls
  attr_accessor :credentials
  attr_accessor :csrf_token
  attr_accessor :session_cookie
  attr_accessor :authentication_code
  attr_accessor :access_token

  def initialize
    project_root = File.dirname(File.absolute_path(__FILE__)) + '/../'
    self.credentials = YAML::load(File.open(project_root + 'config/app_credentials.yml'))
    self.login
  end

  def self.instance
    return @@instance ||= ApiCalls.new
  end

  def get_csrf_token
    res = HTTParty.get("#{self.credentials['host']}/api/login.json")
    self.csrf_token = JSON.parse(res.body)['data']['authenticity_token']
    self.session_cookie = res.response['set-cookie'].split(';').first
  end

  def login
    get_csrf_token
    res = HTTParty.post("#{self.credentials['host']}/api/login.json", {query: {authenticity_token: self.csrf_token, user: {email: self.credentials['email'], password: self.credentials['password']}}, headers: {'Cookie' => self.session_cookie}})
    self.session_cookie = res.response['set-cookie'].split(';').first
  end

  def get_authentication_code
    res = HTTParty.get("#{self.credentials['host']}/oauth/authorize.json", query: {access_token: self.access_token, response_type: 'code', scope: 'public', client_id: self.credentials['client_id'], redirect_uri: self.credentials['redirect_uri']}, headers: {'Cookie' => self.session_cookie})
    self.authentication_code = JSON.parse(res.body)['data']['code']
    if self.authentication_code
      self.get_access_token
    else
      self.login
      self.get_authentication_code
    end
  end

  def get_access_token
    res = HTTParty.post("#{self.credentials['host']}/oauth/token.json", {query: {client_id: self.credentials['client_id'], client_secret: self.credentials['client_secret'], code: self.authentication_code, grant_type: 'authorization_code', redirect_uri: self.credentials['redirect_uri']}})
    self.access_token = JSON.parse(res.body)['data']['access_token']
  end

  def create_message sender, receiver, content, subject
    shop = receiver.scan(/_(.*)@/i).flatten.first
    email = receiver.gsub(/_(.*)@/i, '@')
    res = HTTParty.post("#{self.credentials['host']}/api/merchants/messages/create_virtual.json", {query: {access_token: self.access_token, message: {content: content, subject: subject, from: sender}, shop: shop, email: email}, headers: {'Cookie' => self.session_cookie}})
    if res.code == 401
      self.get_authentication_code
      self.create_message(sender, receiver, content, subject)
    end
    return true
  rescue Exception
    return false
  end
end