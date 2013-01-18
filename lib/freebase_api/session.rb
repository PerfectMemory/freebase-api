require 'cgi'
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
      @key = options[:key]
      @query_options = options[:query_options]
    end

    # Execute a MQL read query
    # @see http://wiki.freebase.com/wiki/MQL_Read_Service
    #
    # @param [Hash] query the MQL query
    # @return [Hash] the response
    def mqlread(query, options={})
      params = { :query => query.to_json, :lang => "/lang/#{@query_options[:lang]}", :limit => @query_options[:limit] }.merge(options)
      response = get(surl('mqlread'), params)
      response['result']
    end

    # Execute a Topic query
    # @see http://wiki.freebase.com/wiki/Topic_API0
    #
    # @param [Hash] id the MQL query
    # @return [Hash] the response
    def topic(id, options={})
      params = { :lang => @query_options[:lang], :limit => @query_options[:limit] }.merge(options)
      response = get(surl('topic') + id, options)
      response
    end

    private

    # Return the URL of a Freebase service
    #
    # @param [String] service the service
    # @return [String] the url of the service
    def surl(service)
      service_url = @env == :stable ? API_URL : SANDBOX_API_URL
      service_url = service_url + "/" + service
    end

    # Make a GET request
    #
    # @param [String] url the url to request
    # @param [Hash] params the params of the request
    # @return the request response
    def get(url, params={})
      FreebaseAPI.logger.debug("GET #{url}")
      params[:key] = @key if @key
      response = self.class.get(url, :format => :json, :query => params)
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
        raise FreebaseAPI::Error.new(response['error'])
      end
    end
  end
end