# gems
require 'sinatra/base'
require 'pry'
require 'date'
require 'haml'

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
      Event.includes(:organizer).all.to_json(:include => {:organizer => {:only => :email}})
    end

    # new event
    post '/events' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      request.body.rewind
      data = JSON.parse(request.body.read)
      event = Event.new(data)
      event.organizer = current_user.db_instance
      event.save
      
      event.to_json(:include => {:organizer => {:only => :email}})
    end

    # edit events
    put '/events/:id' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      request.body.rewind
      data = JSON.parse(request.body.read)
      event = Event.find(params[:id])
      return status(403) unless current_user.can_update? event
      event.organizer = current_user.db_instance
      event.update_attributes(data)
      
      event.to_json(:include => {:organizer => {:only => :email}})
    end

    # remove an events
    delete '/events/:id' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      event = Event.find(params[:id])
      return status(403) unless current_user.can_update? event
      event.remove
    end


    # 404
    not_found do
      '404'
    end
  end
end
