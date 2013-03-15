require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'rspec'
require 'freebase-api'
require 'support/helpers'

RSpec.configure do |config|
  config.include FreebaseAPI::Helpers
end

FreebaseAPI.logger.level = Logger::FATAL