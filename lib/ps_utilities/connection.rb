require 'openssl'
require 'base64'
require 'json'
require 'httparty'
require 'ps_utilities/user_actions'

# http://blog.honeybadger.io/ruby-custom-exceptions/
class AuthError < RuntimeError
  attr_reader :url, :credentials
  def initialize(msg="", url="", credentials={})
    @url         = url
    @credentials = credentials
    super(msg)
  end
end

module PsUtilities

  # The PsUtilities, makes it east to work with the Powerschool API
  # @since 0.1.0
  #
  # @note You should use environment variables to initialize your server.
  class Connection

    attr_reader :credentials, :options

    include PsUtilities::StudentActions

    def initialize(attributes: {}, options: {})
      @credentials = attr_defaults.merge(attributes)
      @options     =  opts_defaults.merge(options)

      raise ArgumentError, "missing client_secret" if credentials[:client_secret].nil?  or
                                                      credentials[:client_secret].empty?
      raise ArgumentError, "missing client_id"     if credentials[:client_id].nil?  or
                                                      credentials[:client_id].empty?
      raise ArgumentError, "missing base_uri"      if credentials[:base_uri].nil?  or
                                                      credentials[:base_uri].empty?
    end

    # with no command it just authenticates
    def run(command: nil, params: {})
      authenticate unless token_valid?
      # command  = send(get_api_info)
      # command_to_ps(command)
    end

    private

    # In PowerSchool go to System>System Settings>Plugin Management Configuration>your plugin>Data Provider Configuration to manually check plugin expiration date
    def authenticate
      @options[:headers] ||= {}
      ps_url = credentials[:base_uri] + credentials[:auth_endpoint]
      response = HTTParty.post(ps_url, {headers: auth_headers,
                                        body: 'grant_type=client_credentials'})

      @credentials[:token_expires] = Time.now + response.parsed_response['expires_in'].to_i
      @credentials[:access_token]  = response.parsed_response['access_token'].to_s
      @options[:headers].merge!('Authorization' => 'Bearer ' + credentials[:access_token])

      # throw error if no token returned -- nothing else will work
      raise AuthError.new("No Auth Token Returned",
                          ps_url, credentials
                         ) if credentials[:access_token].empty?
    end

    def token_valid?(tokens = credentials)
      return false if tokens[:access_token].nil?
      return false if tokens[:access_token].empty?
      return false if tokens[:token_expires].nil?
      return false if tokens[:token_expires] <= Time.now
      return true
    end

    def auth_headers
      { 'ContentType' => 'application/x-www-form-urlencoded;charset=UTF-8',
        'Accept' => 'application/json',
        'Authorization' => 'Basic ' + encode_credentials
      }
    end

    def encode_credentials
      ps_auth_text = [ credentials[:client_id],
                       credentials[:client_secret]
                     ].join(':')
      Base64.encode64(ps_auth_text).gsub(/\n/, '')
    end

    def attr_defaults
      { base_uri:       ENV['PS_URL'],
        auth_endpoint:  ENV['PS_AUTH_ENDPOINT'] || '/oauth/access_token',
        client_id:      ENV['PS_CLIENT_ID'],
        client_secret:  ENV['PS_CLIENT_SECRET'],
        # not recommended here - it changes (ok as a parameter though)
        # access_token:   ENV['PS_ACCESS_TOKEN'] || nil,
      }
    end

    def opts_defaults
      {:headers =>
        { 'User-Agent' => "PsUtilitiesGem - v#{PsUtilities::Version::VERSION}",
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'}
      }
    end

  end
end
