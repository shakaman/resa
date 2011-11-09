#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'test_helper'

describe Resa do
  include Rack::Test::Methods

  def app
    Resa::App
  end

  before do
    cleanup
    Resa::Location.import
    Resa::Calendar.import(:test)
    Resa::Location.create(name: 'emptyroom')

    # user
    @admin = User.set(:email => "admin@admin.com", :password => "admin",
                      :password_confirmation => 'admin', :permission_level => -1)

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

  describe 'login' do
    before do
      post '/signup', {'user[email]' => @admin.email, 'user[password]' => 'admin', 'user[password_confirmation]' => 'admin'}
      follow_redirect!
      get '/logout'
    end

    it 'should login' do
      post '/login', {'email' => @admin.email, 'password' => 'admin'}
      follow_redirect!

      assert_equal 'http://example.org/', last_request.url
      #assert cookie_jar['user']
      assert last_request.env['rack.session'][:user]
      assert last_response.ok?
    end
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
