require 'openssl'
require 'base64'
require 'json'
require 'httparty'

module PsUtilties

  # The PsUtilties, makes it east to work with the Powerschool API
  # @since 0.1.0
  #
  # @note You should use environment variables to initialize your server.
  class Connection

    attr_reader :api_credentials, :authenticated, :options

    include PsUtilities::UserActions
    
    BASE_URI = ENV['PS_URL'] || 'https://partner3.powerschool.com'
    AUTH_ENDPOINT = '/oauth/access_token'

    def initialize(credentials: {}, options: {})
      @api_credentials = defaults.merge(credentials)
      if ( @api_credentials[:client_secret].nil?  || @api_credentials[:client_id].nil?) &&
         @api_credentials[:access_token].nil?
          raise AuthenticationError, 'Access token or api credentials are required'
      end
      if ( @api_credentials[:client_secret].empty? || @api_credentials[:client_id].empty?) &&
         @api_credentials[:access_token].empty?
          raise AuthenticationError, 'Access token or api credentials are required'
      end
      @options =  {:headers => { 'User-Agent' => "Ruby Powerschool #{VERSION}",
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json'
                                }
                  }.merge(options)
    end

    # def options(other = {})
    #   if !@authenticated
    #     authenticate
    #   end
    #   @options.merge(other)
    # end

    def authenticate(force = false)
      @authenticated = false
      if ! @api_credentials[:access_token]
        ps_auth_tx = [ @api_credentials[:client_id],
                       @api_credentials[:client_secret]
                     ].join(':')
        ps_auth_64 = Base64.encode64(ps_auth_tx).gsub(/\n/, '')
        headers = {
          'ContentType' => 'application/x-www-form-urlencoded;charset=UTF-8',
          'Accept' => 'application/json',
          'Authorization' => 'Basic ' + ps_auth_64 }
        response = HTTParty.post( BASE_URI +
                                  AUTH_ENDPOINT,
                                  { headers: headers,
                                    body: 'grant_type=client_credentials'} )
        @options[:headers] ||= {}
        if response.parsed_response && response.parsed_response['access_token']
          @api_credentials[:access_token] = response.parsed_response['access_token']
        end
      end
      if @api_credentials[:access_token]
        @options[:headers].merge!('Authorization' => 'Bearer ' + @api_credentials[:access_token])
        @authenticated = true
      else
        raise AuthenticationError.new("Could not authenticate: %s -- headers: %s" % [response.inspect, headers])
      end
      return @authenticated
    end

    private

    def defaults
      { client_id:      ENV['PS_CLIENT_ID'],
        client_secret:  ENV['PS_CLIENT_SECRET'],
        access_token:   ENV['PS_ACCESS_TOKEN'] || nil }
    end
  end
end
