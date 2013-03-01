require 'logger'

require 'freebase_api/session'
require 'freebase_api/image'
require 'freebase_api/version'
require 'freebase_api/topic'
require 'freebase_api/attribute'
require 'freebase_api/exceptions'
require 'freebase_api/ext/hash'

# FreebaseAPI is a library to use the Freebase API
#
# It provides :
# - a Data mapper
# - a low level class to use directly the Freebase API (Topic, Search, MQLRead)
#
# @see http://wiki.freebase.com/wiki/Freebase_API
module FreebaseAPI
  class << self
    attr_accessor :logger, :session

    def init_logger
      logger = Logger.new(STDERR)
      logger.level = Logger::WARN
      logger.progname = "FreebaseAPI"
      self.logger = logger
    end
  end
end

FreebaseAPI.init_logger
FreebaseAPI.session = FreebaseAPI::Session.new