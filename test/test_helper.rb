# encoding: UTF-8

ENV['RACK_ENV'] ||= 'test'

require 'sinatra'
require_relative '../lib/resa'

Resa.initialize

def cleanup
  User.all.each do |u|
    User.delete(u.id)
  end
  Mongoid.purge!
end

require 'rack/test'
require 'minitest/autorun'
