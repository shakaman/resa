# gems
require 'sinatra/base'
require 'pry'
require 'date'
require 'haml'

module Resa
  class App < Sinatra::Base
    set :static, true
    set :public,  File.dirname(__FILE__) + '/../../public'
    set :views, File.dirname(__FILE__) + '/../../views'

    before do
      content_type 'application/json', :charset => 'utf-8'
    end

    # Return rooms available now
    get '/' do
      content_type 'text/html', :charset => 'utf-8'
      haml :index, :format => :html5
    end

    # Return list of rooms
    get '/rooms' do
      Location.all.to_json
    end

    # Return all events
    get '/events' do
      Event.all.to_json
    end

    # new event
    post '/events' do
      request.body.rewind
      data = JSON.parse(request.body.read)
      puts data
      event = Event.create!(data)
      event.to_json
    end

    # edit events
    put '/events/:id' do
      request.body.rewind
      data = JSON.parse(request.body.read)
      event = Event.find(params[:id])
      event.update_attributes(data)
      event.to_json
    end

    # remove an events
    delete '/events/:id' do
      request.body.rewind
      Events.get(data['_id']).remove
    end

    # 404
    not_found do
      '404'
    end
  end
end
