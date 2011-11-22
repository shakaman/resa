# gems
require 'sinatra/base'
require 'rack-flash'
require 'date'
require 'haml'
require 'pony'
require 'yajl'

module Resa
  class App < Sinatra::Base

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

    # Return rooms available now
    get '/' do
      session[:return_to] = '/'
      login_required
      content_type 'text/html', :charset => 'utf-8'
      haml :index, :format => :html5, :layout => :calendar
    end

    # Return list of rooms
    get '/rooms' do
      session[:return_to] = '/'
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
      '404'
    end

  end
end
