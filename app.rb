require 'sinatra'
require 'sass'
require 'mixpanel'
require 'gibbon'

require './helpers/helpers.rb'
require './config/initializers/load_keys.rb'

use Mixpanel::Tracker::Middleware, KEYS["mixpanel"], :insert_js_last => true

# require_relative does not exist in ruby 1.8.7
# This is a fallback -- http://stackoverflow.com/a/4718414/951432
unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

configure do
  set :sass, :style => :compressed

  set :gb, Gibbon.new(KEYS["mailchimp"])
  set :list_id, settings.gb.lists({:filters => { :list_name => "nplanding" }})["data"].first["id"]
end

before do
  @mixpanel = Mixpanel::Tracker.new(KEYS["mixpanel"], request.env, true)
end

get '/stylesheets/:filename.css' do
  content_type 'text/css', :charset => 'utf-8'
  filename = "#{params[:filename]}"
  render :sass, filename.to_sym, :views => './views/stylesheets'
end

get '/' do
  @mixpanel.track_event("Home Page View")
  @javascripts = ['/javascripts/mixpanel_init.js', '/javascripts/jquery.js', '/javascripts/index.js']

  erb :index
end

post '/newsletter' do
  email_regex = /^[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/

  if params[:email] =~ email_regex and !email_exists?('newsletter.txt', params[:email])
    add_to_newsletter('newsletter.txt', params[:email])

    settings.gb.listSubscribe({ :id => settings.list_id,
                                :email_address => params[:email],
                                :merge_vars => {:fname => params[:fname], :lname => params[:lname]},
                                :double_optin => false,
                                :send_welcome => true })
  end

  redirect to('/') unless request.xhr?
end
