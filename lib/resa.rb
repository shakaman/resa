# gems
require 'mongoid'
require 'kaminari/sinatra'
require 'pathname'
require 'sinatra-authentication'
require 'user'


module Resa
  autoload :App,        'resa/app'
  autoload :Location,   'resa/location'
  autoload :Calendar,   'resa/calendar'
  autoload :Event,      'resa/event'

  @@config = nil

  class << self
    attr_accessor :config
  end

  def self.root
    return @root_path if @root_path
    @root_path = File.expand_path("../..", __FILE__)
  end

  # Initialize the application
  def self.initialize
    Mongoid.logger = nil
    Mongoid.load! "#{self.root}/config/mongoid.yml"
    self.config = YAML.load_file(self.config_file)
  end

  protected

  # Load my conf
  def self.config_file
    File.join root, 'config' '/config.yml'
  end
end
