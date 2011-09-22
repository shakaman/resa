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

    helpers do
      def find_room(id)
        @room = Room.where(:name => id).first
    rescue Mongoid::Errors::DocumentNotFound, BSON::InvalidObjectId
        halt 404, '404 - Page not found'
      end
    end

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
      Room.list.to_json
    end

    # Return room's availability for the current day
    get '/rooms/:id' do
      find_room(params[:id])
      @room.to_json
    end

    # Return reservations of the day
    get '/rooms/:id/reservations' do
      find_room(params[:id])
      reservations = @room.reservations_for_a_day

      reservations.to_json
    end

    # Return reservations for a month.
    get '/rooms/:id/reservations/:year/:month' do
      find_room(params[:id])
      reservations = @room.reservations_for_a_month(params[:year], params[:month])

      reservations.to_json
    end


    # Return reservations for a day.
    get '/rooms/:id/reservations/:year/:month/:day' do
      find_room(params[:id])
      reservations = @room.reservations_for_a_day("#{params[:year]}-#{params[:month]}-#{params[:day]}")

      reservations.to_json
    end

    # Add a new reservation for a room.
    post '/rooms/:id/reservations' do
      request.body.rewind
      data = JSON.parse(request.body.read)

      if data.nil?
        status 404
      else
        find_room(params[:id])
        halt 404, '404 - Room does not exist' unless @room

        begin
          dtstart = Time.parse(data['dtstart'])
          dtend = Time.parse(data['dtend'])
          raise unless dtstart < dtend

          raise unless @room.available?(dtstart, dtend)
        rescue
          halt 404, '404 - Date error'
        end

        @room.events.create!(data)

        # export ical?
        #Calendar.export

        status 201
      end
    end

    # 404
    not_found do
      '404'
    end
  end
end
