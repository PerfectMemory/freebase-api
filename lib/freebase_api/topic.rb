module FreebaseAPI
  class Topic

    # The maximum number of property values to return.
    PROPERTIES_LIMIT = 100

    attr_reader :properties

    class << self
      # Returns a new Topic filled with all the Freebase properties
      #
      # @param [String] id the Freebase ID
      # @param [Hash] options the options
      # @return [Topic] the topic
      def get(id, options={})
        topic = Topic.new(id, options)
        topic.sync
        topic
      end

      # Search using a query and returns the results as a hash of topics score based
      #
      # @param [String] query the string query
      # @param [Hash] options the options
      # @return [Hash] the topics
      def search(query, options={})
        hash = {}
        FreebaseAPI.session.search(query, options).each do |topic|
          hash[topic['score'].to_f] = Topic.new(topic['mid'], :data => construct_data(topic))
        end
        hash
      end

      private

      # @private
      def construct_data(topic)
        lang = topic['lang']
        data = {
          "id" => topic['mid'],
          "lang" => lang,
          "property" => {
            "/type/object/name" => {
              "valuetype" => "string",
              "values" => [
                {
                 "text" => "#{topic['name']}",
                 "lang" => lang,
                 "value" => "#{topic['name']}"
                }
              ]
            }
          }
        }
        data["property"]["/common/topic/notable_for"] = {
          "valuetype" => "object",
          "values" => [
            {
             "text" => topic['notable']['name'],
             "lang" => lang,
             "id" => topic['notable']['id']
            }
          ],
        } if topic.has_key?('notable')
        data
      end
    end

    def initialize(id, options={})
      @properties = {}
      @excluded_properties = parse_exclusion(options.delete(:exclude))
      @options = { :filter => 'commons' }.merge(options)
      @data = { 'id' => id }.merge(options[:data] || {})
      build
    end

    def id
      @data['id']
    end

    def text
      @data['text']
    end

    def lang
      @data['lang']
    end

    def name
      @name ||= extract_name
    end

    def types
      @types ||= extract_types
    end

    def description
      @description ||= extract_description
    end

    def property(name)
      @properties[name]
    end

    def properties_domains
      domains = {}
      properties.keys.each do |prop|
        d = prop.split('/')[1]
        domains[d] ||= 0
        domains[d] += properties[prop].size
      end
      domains
    end

    def sync
      @data = FreebaseAPI.session.topic(self.id, @options)
      build
    end

    def image(options={})
      FreebaseAPI::Image.get(self.id, options)
    end

    def inspect
      "#<#{self.class}:0x#{self.__id__.to_s(16)} id: \"#{self.id}\", name: \"#{self.name}\">"
    end

    private

    def extract_name
      if names = property('/type/object/name')
        names.first.value
      else
        text
      end
    end

    def extract_types
      if types = property('/type/object/type')
        types.map(&:id)
      else
        []
      end
    end

    def extract_description
      if articles = property('/common/topic/article')
        articles.first.property('/common/document/text').first.value
      end
    end

    def parse_exclusion(exclusion)
      if !exclusion
        []
      elsif exclusion.is_a?(Array)
        exclusion
      else
        [exclusion]
      end
    end

    def build
      if @data['property']
        FreebaseAPI.logger.debug("Building topic #{self.id} : #{@data['property'].size} properties")
        @data['property'].each do |key, value|
          build_property(key, value)
        end
      end
      invalidate_lazy_properties
    end

    def build_property(property, content)
      unless @excluded_properties.select { |p| property.start_with?(p) }.any?
        case content['valuetype'].to_sym
        when :compound, :object
          # Note : some referenced topics have empty ids, we need to exclude them
          @properties[property] = content['values'].reject { |s| s['id'].empty? }.map { |at| Topic.new(at['id'], :data => at) }
        else
          @properties[property] = content['values'].map { |at| Attribute.new(at, :type => content['valuetype']) }
        end
      end
    end

    def invalidate_lazy_properties
      @name = nil
      @types = nil
      @description = nil
    end
  end
end