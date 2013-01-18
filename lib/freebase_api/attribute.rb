module FreebaseAPI
  # Attribute can be any Freebase data type
  class Attribute

    attr_accessor :type

    def initialize(data, options={})
      @data = data
      @type = options[:type]
    end

    def value
      @data['value']
    end

    def text
      @data['text']
    end

    def lang
      @data['lang']
    end

    def type
      @type
    end

  end
end