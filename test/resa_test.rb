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
end
