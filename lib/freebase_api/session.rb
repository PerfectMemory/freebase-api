require 'httparty'
require 'json'

module FreebaseAPI
  class Session
    include HTTParty
    disable_rails_query_string_format

    attr_reader :env, :key, :query_options

    # URIs of the Freebase API
    API_URL = "https://www.googleapis.com/freebase/v1"
    SANDBOX_API_URL = "https://www.googleapis.com/freebase/v1sandbox"

    # Freebase default values
    DEFAULT_LIMIT = 10
    DEFAULT_LANGUAGE = :en

    def initialize(options={})
      options = { :env => :stable, :query_options => { :limit => DEFAULT_LIMIT, :lang => DEFAULT_LANGUAGE } }.deep_merge(options)
      @env = options[:env]
      @key = options[:key] || ENV['GOOGLE_API_KEY']
      @query_options = options[:query_options]
    end

    # Execute a MQL read query
    # @see http://wiki.freebase.com/wiki/MQL_Read_Service
    #
    # @param [Hash] query the MQL query
    # @return [Hash] the response
    def mqlread(query, options={})
      params = { :query => query.to_json, :lang => "/lang/#{@query_options[:lang]}", :limit => @query_options[:limit] }.merge(options)
      response = get(surl('mqlread'), params, format: :json)
      response['result']
    end

    # Execute a Topic query
    # @see http://wiki.freebase.com/wiki/Topic_API
    #
    # @param [String] id the topic ID
    # @param [Hash] options the MQL query options
    # @return [Hash] the response
    def topic(id, options={})
      params = { :lang => @query_options[:lang], :limit => @query_options[:limit] }.merge(options)
      get(surl('topic') + id, params, format: :json)
    end

    # Execute a Image Service query
    # @see http://wiki.freebase.com/wiki/ApiImage
    #
    # @param [String] id the topic ID
    # @param [Hash] options the Image Service options
    # @return [Hash] the response
    def image(id, options={})
      params = options
      get(surl('image') + id, params).body
    end

    private

    # Return the URL of a Freebase service
    #
    # @param [String] service the service
    # @return [String] the url of the service
    def surl(service)
      service_url = @env == :stable ? API_URL : SANDBOX_API_URL
      service_url = service_url + "/" + service
      service_url.gsub!('www', 'usercontent') if service.to_s == 'image'
      service_url
    end

    # Make a GET request
    #
    # @param [String] url the url to request
    # @param [Hash] params the params of the request
    # @return the request response
    def get(url, params={}, options={})
      FreebaseAPI.logger.debug("GET #{url}")
      params[:key] = @key if @key
      response = self.class.get(url, :format => options[:format], :query => params)
      handle_response(response)
    end

    # Handle the response
    #
    # If success, return the response body
    # If failure, raise an error
    def handle_response(response)
      case response.code
      when 200..299
        response
      else
        if response.request.format == :json
          raise FreebaseAPI::ServiceError.new(response['error'])
        else
          raise FreebaseAPI::NetError.new('code' => response.code, 'message' => response.response.message)
        end
      end
    end
  end
end