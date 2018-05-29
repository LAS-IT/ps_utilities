require 'openssl'
require 'base64'
require 'json'
require 'httparty'
require 'ps_utilities/user_actions'

module PsUtilities

  # The PsUtilities, makes it east to work with the Powerschool API
  # @since 0.1.0
  #
  # @note You should use environment variables to initialize your server.
  class Connection

    attr_reader :credentials, :authenticated, :options

    include PsUtilities::UserActions

    def initialize(attributes: {}, options: {})
      @credentials = attr_defaults.merge(attributes)
      @options         =  opts_defaults.merge(options)

      raise ArgumentError, "missing client_secret"  if @credentials[:client_secret].nil?  or
                                                      @credentials[:client_secret].empty?
      raise ArgumentError, "missing client_id"      if @credentials[:client_id].nil?  or
                                                      @credentials[:client_id].empty?
      raise ArgumentError, "missing base_uri"       if @credentials[:base_uri].nil?  or
                                                      @credentials[:base_uri].empty?
    end

    def run
      authenticate unless token_valid?
      # command  = send(get_api_info)
      # response = send_command_to_ps(command)
    end

    private

    # In PowerSchool go to System>System Settings>Plugin Management Configuration>your plugin>Data Provider Configuration to manually check plugin expiration date
    def authenticate
      @credentials[:access_token] = get_token()
      @options[:headers].merge!('Authorization' => 'Bearer ' + @credentials[:access_token])
      raise AuthenticationError.new("Could not authenticate") unless @credentials[:access_token]
      @authenticated = true
    end

    def token_valid?
      return false if @credentials[:access_token].nil?
      return false if @credentials[:token_expires] <= Time.now
      return true
    end

    def get_token
      response = HTTParty.post( credentials[:base_uri] +
                                credentials[:auth_endpoint],
                                { headers: auth_headers,
                                  body: 'grant_type=client_credentials'} )
      @options[:headers] ||= {}
      if response.parsed_response && response.parsed_response['access_token']
        @credentials[:token_expires] = Time.now + response.parsed_response['expires_in'].to_i
        response.parsed_response['access_token']
      end
    end

    def auth_headers()
      ps_auth_64 = encode_api_credentials
      { 'ContentType' => 'application/x-www-form-urlencoded;charset=UTF-8',
        'Accept' => 'application/json',
        'Authorization' => 'Basic ' + ps_auth_64 }
    end

    def encode_api_credentials()
      ps_auth_tx = [ credentials[:client_id],
                     credentials[:client_secret]
                   ].join(':')
      Base64.encode64(ps_auth_tx).gsub(/\n/, '')
    end

    def attr_defaults
      { base_uri:       ENV['PS_URL'],
        auth_endpoint:  ENV['PS_AUTH_ENDPOINT'] || '/oauth/access_token',
        client_id:      ENV['PS_CLIENT_ID'],
        client_secret:  ENV['PS_CLIENT_SECRET'],
        access_token:   ENV['PS_ACCESS_TOKEN'] || nil }
    end

    def opts_defaults
      { :headers => { 'User-Agent' => "Ruby Powerschool",
                      'Accept' => 'application/json',
                      'Content-Type' => 'application/json'}
      }
    end

    #
    # def options(other = {})
    #   if !@authenticated
    #     authenticate
    #   end
    #   @options.merge(other)
    # end

  end
end
