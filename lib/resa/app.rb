# gems
require 'sinatra/base'
require 'date'
require 'haml'

module Resa
  class App < Sinatra::Base
    set :static, true
    set :public,  File.dirname(__FILE__) + '/../../public'
    set :views, File.dirname(__FILE__) + '/../../views'

    helpers do
      def find_room(id)
        @room = Room.where(:name => id).without(:_id).first
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

    # Return reservations for a day
    get '/rooms/:id/reservations/:year/:month/:day' do
      find_room(params[:id])
      reservations = @room.reservations_for_a_day("#{params[:year]}-#{params[:month]}-#{params[:day]}")

      reservations.to_json
    end

    # create new event
    post '/reservations' do
      data = JSON.parse(request.body.string)

      if data.nil? then
        status 404
      else
        # check if room exist
        find_room(data[:room])

        # check if date is in a good format
        begin
          Time.parse("#{data[:dtstart]}") && Time.parse("#{data[:dtend]}")
        rescue
          halt 404, '404 - Date error'
        end

        # check if the room is available for this date
        @room.check_availability(data[:dtstart], data[:dtend])

        # create event

        # export ical
        # Calendar.export
      end
    end

    # 404
    not_found do
      '404'
    end
  end
end
