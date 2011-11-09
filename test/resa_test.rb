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
    Resa::Location.import
    Resa::Calendar.import(:test)
    Resa::Location.create(name: 'emptyroom')

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

  it "list the rooms (not logged)" do
    get '/rooms'
    last_response.status.must_equal 302
  end
end
