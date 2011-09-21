#!/usr/bin/env ruby
# encoding: UTF-8

require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

describe Resa do
  include Rack::Test::Methods

  def app
    Resa::App
  end

  it "list of rooms" do
    get '/rooms'
    last_response.status.must_equal 200
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
