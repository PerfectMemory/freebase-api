module FreebaseAPI
  # A class for returning errors from the Freebase API
  class Error < StandardError
    attr_accessor :code, :message, :errors

    def initialize(params)
      FreebaseAPI.logger.error("#{params['message']} (#{params['code']})")
      self.code = params['code']
      self.message = params['message']
    end

    def to_s
      "#{self.message} (#{self.code})"
    end
  end

  class ServiceError < Error
    def initialize(params)
      super
      self.errors = params['errors']
    end
  end

  class NetError < Error ;; end
end