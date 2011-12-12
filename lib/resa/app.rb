# gems
require 'sinatra/base'
require 'rack-flash'
require 'date'
require 'haml'
require 'pony'
require 'yajl'

module Resa
  class App < Sinatra::Base

    register Kaminari::Helpers::SinatraHelpers
    use Rack::Session::Cookie, :secret => 'cat on keyborad'
    use Rack::Flash

    set :static, true
    set :public,  File.dirname(__FILE__) + '/../../public'
    set :views, File.dirname(__FILE__) + '/../../views'

    helpers do
      def send_registration_mail
        Pony.mail(:to => params[:user][:email],
                  :from => "no-reply@#{Resa.config[:app][:host]}",
                  :subject => '[RESA] Account created.',
                  :body => "Hi,
                  You can now login with email and password:
                  #{params[:user][:email]} / #{params[:user][:password]}

                  http://#{Resa.config[:app][:host]}")

      rescue Errno::EPIPE, Errno::ECONNREFUSED
        STDERR.puts "Mail Account created Fail."
      end
    end

    get '/' do
      session[:return_to] = '/'
      login_required
      content_type 'text/html', :charset => 'utf-8'
      haml :index, :format => :html5, :layout => :calendar
    end

    # Return list of rooms
    get '/rooms.json' do
      session[:return_to] = '/'
      login_required
      content_type 'application/json', :charset => 'utf-8'
      Location.all.to_json
    end

    get '/rooms' do
      session[:return_to] = '/'
      login_required
      @rooms = Location.page(params[:page])
      haml :rooms, :format => :html5, :layout => :layout
    end

    get '/rooms/new' do
      redirect '/' unless current_user && current_user.admin?
      @room = Location.new :name => "", :color => '#555555'
      @room._id = nil
      haml :'rooms/edit', :format => :html5, :layout => :layout
    end

    post '/rooms/' do
      redirect '/' unless current_user && current_user.admin?
      @room = Location.create(params[:room])
      if @room.persisted?
        flash[:notice] = "Location created."
        redirect "/rooms/#{@room.id}/edit"
      else
        flash[:error] = "Location not created."
        @room._id = nil
        haml :'rooms/edit', :format => :html5, :layout => :layout
      end
    end

    get '/rooms/:id/edit' do
      redirect '/' unless current_user && current_user.admin?
      @room = Location.find params[:id]
      haml :'rooms/edit', :format => :html5, :layout => :layout
    end

    get '/rooms/:id/delete' do # FIXME use a delete method here.
      redirect '/' unless current_user && current_user.admin?
      @room = Location.find params[:id]
      @room.delete
      redirect "/rooms"
    end

    post '/rooms/:id' do
      redirect '/' unless current_user && current_user.admin?
      @room = Location.find params[:id]
      if @room.update_attributes(params[:room])
        flash[:notice] = "Location updated."
      else
        flash[:error] = "Location not updated."
      end
      redirect "/rooms/#{@room.id}/edit"
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
      data = Yajl::Parser.parse(request.body.read)
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
      data = Yajl::Parser.parse(request.body.read)
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

    get '/signup' do
      if current_user && current_user.admin?
        haml get_view_as_string("signup.haml")
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
        send_registration_mail
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
      haml :not_found, :format => :html5, :layout => :layout
    end

  end
end
