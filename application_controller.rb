require 'eventmachine'
require 'em-websocket'
require 'json'
require 'pry'
require 'thin'
require 'sinatra/base'
require_relative 'game'

class ApplicationController < Sinatra::Base

  configure do
    set :threaded, false
  end

  get '/' do
    erb :'index.html'
  end

  get '/assets/js/application.js' do
    content_type :js
    erb :'application.js'
  end

  get '/assets/css/style.css' do
    content_type :css
    erb :'style.css'
  end

end