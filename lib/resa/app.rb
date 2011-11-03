# gems
require 'sinatra/base'
require 'pry'
require 'date'
require 'haml'
require 'sinatra-authentication'

module Resa
  class App < Sinatra::Base

    use Rack::Session::Cookie, :secret => 'cat on keyborad'

    register Sinatra::SinatraAuthentication

    set :static, true
    set :public,  File.dirname(__FILE__) + '/../../public'
    set :views, File.dirname(__FILE__) + '/../../views'


    # Return rooms available now
    get '/' do
      login_required
      content_type 'text/html', :charset => 'utf-8'
      haml :index, :format => :html5
    end

    # Return list of rooms
    get '/rooms' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      Location.all.to_json
    end

    # Return all events
    get '/events' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      Event.all.to_json
    end

    # new event
    post '/events' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      request.body.rewind
      data = JSON.parse(request.body.read)
      event = Event.create!(data)
      event.to_json
    end

    # edit events
    put '/events/:id' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      request.body.rewind
      data = JSON.parse(request.body.read)
      event = Event.find(params[:id])
      event.update_attributes(data)
      event.to_json
    end

    # remove an events
    delete '/events/:id' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      request.body.rewind
      Events.get(data['_id']).remove
    end


    # 404
    not_found do
      '404'
    end
  end
end
