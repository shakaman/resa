# gems
require 'sinatra/base'
require 'pry'
require 'date'
require 'haml'
require 'sinatra-authentication'

module Resa
  class App < Sinatra::Base

    use Rack::Session::Cookie, :secret => 'cat on keyborad'


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
      event.organizer = current_user.db_instance
      event.update_attributes(data)
      
      event.to_json(:include => {:organizer => {:only => :email}})
    end

    # remove an events
    delete '/events/:id' do
      login_required
      content_type 'application/json', :charset => 'utf-8'
      Event.find(params[:id]).remove
    end

    get '/signup' do
      if current_user && current_user.admin?
        haml get_view_as_string("signup.haml"), :layout => use_layout?
      else
        redirect '/'
      end
    end

    post '/signup' do
      redirect '/' unless current_user && current_user.admin?
      @user = User.set(params[:user])
      if @user.valid && @user.id
        # Do not login user we only want admin create user
        # session[:user] = @user.id
        if Rack.const_defined?('Flash')
          flash[:notice] = "Account created."
        end
        redirect '/'
      else
        if Rack.const_defined?('Flash')
          flash[:notice] = "There were some problems creating your account: #{@user.errors}."
        end
        redirect '/signup?' + hash_to_query_string(params['user'])
      end
    end

    # register after redefinition of signup
    register Sinatra::SinatraAuthentication

    # 404
    not_found do
      '404'
    end

  end
end
