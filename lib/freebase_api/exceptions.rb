module FreebaseAPI
  # A class for returning errors from the Freebase API
  class Error < StandardError
    attr_accessor :code, :message, :errors

    def initialize(params)
      FreebaseAPI.logger.error("#{params['message']} (#{params['code']}) : #{params['errors'].first['reason']}")
      self.code = params['code']
      self.message = params['message']
      self.errors = params['errors']
    end

    def to_s
      "<#{self.class} code=\"#{self.code}\" message=\"#{self.message}\" reason=\"#{self.errors.first['reason']}\">"
    end
  end
end