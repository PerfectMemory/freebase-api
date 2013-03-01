module FreebaseAPI
  class Image

    attr_reader :id

    class << self
      def get(id, options={})
        image = Image.new(id, options)
        image.retrieve
        image
      end
    end

    def initialize(id, options={})
      @data = nil
      @options = options
      @id = id
    end

    def retrieve
      @data = FreebaseAPI.session.image(self.id, @options)
    end

    def store(filename)
      File.open(filename, 'wb') do |f|
        f.write data
      end
    end

    def size
      data.size
    end

    def inspect
      self.to_s
    end

    private

    def data
      @data || retrieve
    end
  end
end