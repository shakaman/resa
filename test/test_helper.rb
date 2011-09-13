# encoding: UTF-8

# XXX dont like the LOAD_PATH modification, use a gemspec
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['RACK_ENV'] ||= 'test'

require 'sinatra'
require File.expand_path '../../lib/resa', __FILE__

Resa.initialize

require 'rack/test'
require 'minitest/autorun'
