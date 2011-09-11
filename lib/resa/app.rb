# gems
require 'sinatra/base'
require 'date'

module Resa
  class App < Sinatra::Base

    # Return rooms available now
    get '/' do
    end

    # Return list of rooms
    get '/rooms' do
      Rooms.list
    end

    # Return room's availability for the current day
    get '/rooms/:room_name' do
    end

    # Return room's availability for the next day
    get '/rooms/:room_name/tomorrow' do
    end
    
    # test
    get '/calendar' do
      Calendar.test
    end

  end
end
