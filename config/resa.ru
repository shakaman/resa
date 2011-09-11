$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'resa'

Resa.initialize

run Resa::App
