$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'freebase-api'
require 'support/helpers'

RSpec.configure do |config|
  config.include FreebaseAPI::Helpers
end

FreebaseAPI.logger.level = Logger::FATAL