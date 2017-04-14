dev = ENV['RACK_ENV'] == 'development'

if dev
  require 'logger'
  logger = Logger.new($stdout)
end

require 'rack/unreloader'
Unreloader = Rack::Unreloader.new(:subclasses=>%w'Roda Sequel::Model', :logger=>logger, :reload=>dev){Latoto::App}
require_relative 'models'
Unreloader.require('latoto.rb'){'Latoto'}
run(dev ? Unreloader : Latoto::App.freeze.app)
