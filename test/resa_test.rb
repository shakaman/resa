#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'test_helper'

describe Resa do
  include Rack::Test::Methods

  def app
    Resa::App
  end

  before do
    Mongoid.purge!
    Resa::Calendar.import(:test)
    Resa::Room.create(name: 'emptyroom')

    # Fake dates.
    dtstart = Time.parse('10:00')
    dtend = Time.parse('19:00')

    # Minimal field set to describe a new reservation.
    @reservation = {
      'title'     => 'réunion super importante',
      'dtstart'   => dtstart,
      'dtend'     => dtend,
      'organizer' => 'tester'
    }
  end

  it "should return 404 on unavailable routes" do
    get '/toto'
    last_response.status.must_equal 404
  end

  it "list the rooms" do
    get '/rooms'
    last_response.status.must_equal 200
    JSON.parse(last_response.body).must_equal Resa::Room.list
  end

  it "should list reservations for a specific room" do
    get 'rooms/bas'
    last_response.status.must_equal 200
    res = JSON.parse(last_response.body)
    res.must_be_kind_of Hash
    res.keys.must_include 'events'
    res.keys.must_include 'name'
    res['events'].must_be_kind_of Array
    res['name'].must_equal 'bas'
    res['events'].first.must_include 'dtstart'
    res['events'].first.must_include 'dtend'
    res['events'].first.must_include 'title'
    res['events'].first.must_include 'organizer'
  end

  #it "should list reservations for the current day" do
    #get 'rooms/bas/reservations'
    #last_response.status.must_equal 200
    #res = JSON.parse(last_response.body)
  #end

  it "should list reservations for a specific month" do
    get 'rooms/bas/reservations/2011/09'
    last_response.status.must_equal 200
    res = JSON.parse(last_response.body)
    res.size.must_equal 1
    res.first['title'].must_equal 'event 1'

    get 'rooms/bas/reservations/2011/08'
    last_response.status.must_equal 200
    res = JSON.parse(last_response.body)
    res.must_be_empty
  end


  it "should list reservations for a specific date" do
    get 'rooms/bas/reservations/2011/09/20'
    last_response.status.must_equal 200
    res = JSON.parse(last_response.body)
    res.size.must_equal 1
    res.first['title'].must_equal 'event 1'

    get 'rooms/bas/reservations/2011/09/19'
    last_response.status.must_equal 200
    res = JSON.parse(last_response.body)
    res.must_be_empty
  end

  it "should allow to book a room" do
    post 'rooms/emptyroom/reservations', @reservation.to_json
    last_response.status.must_equal 201

    get 'rooms/emptyroom/reservations'
    res = JSON.parse(last_response.body)
    res.first['name'].must_equal @reservation['name']
  end

  # tests.ics
  # event 1:
  #   room:   bas
  #   start:  2011-09-20 12:00
  #   end:    2011-09-23 13:00
  # event 2:
  #   room:   haut
  #   start:  2011-09-21 14:30
  #   end:    2011-09-21 15:30
  # event 3:
  #   room:   cuisine
  #   start:  2011-09-24
  #   end:    2011-09-24
end
