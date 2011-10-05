# encoding: UTF-8

ENV['RACK_ENV'] ||= 'test'

require 'sinatra'
require_relative '../lib/resa'

Resa.initialize

require 'rack/test'
require 'minitest/autorun'
