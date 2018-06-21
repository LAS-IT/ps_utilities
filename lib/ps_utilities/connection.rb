require 'openssl'
require 'base64'
require 'json'
require 'httparty'
require 'ps_utilities/pre_built_get'
require 'ps_utilities/pre_built_put'
require 'ps_utilities/pre_built_post'

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

    attr_reader :credentials, :headers, :base_uri, :auth_path, :version

    include PsUtilities::PreBuiltGet
    include PsUtilities::PreBuiltPut
    include PsUtilities::PreBuiltPost

    def initialize(attributes: {}, headers: {})
      @credentials = attr_defaults.merge(attributes)
      @headers     = header_defaults.merge(headers)
      @base_uri    = credentials[:base_uri]
      @auth_path   = credentials[:auth_endpoint]
      @version     = "v#{PsUtilities::Version::VERSION}"

      raise ArgumentError, "missing client_secret" if credentials[:client_secret].nil?  or
                                                      credentials[:client_secret].empty?
      raise ArgumentError, "missing client_id"     if credentials[:client_id].nil?  or
                                                      credentials[:client_id].empty?
      raise ArgumentError, "missing base_uri"      if credentials[:base_uri].nil?  or
                                                      credentials[:base_uri].empty?
    end

    # with no command it just authenticates
    def run(command: nil, params: {}, api_path: "", options: {})
      authenticate   unless token_valid?
      case command
      when nil, :authenticate
        # authenticate            unless token_valid?
      when :get, :put, :post
        api(command, api_path, options)         unless api_path.empty?
      # when :get, :put, :post
      #   send(:api, command, api_path, options)  unless api_path.empty?
      else
        send(command, params)
      end
    end

    private

    # options = {query: {}}
    # verb = :get, :put, :post, etc
    def api(verb, api_path, options={})
      count   = 0
      retries = 3
      ps_url  = base_uri + api_path
      options = options.merge(headers)
      begin
        HTTParty.send(verb, ps_url, options)
      rescue Net::ReadTimeout, Net::OpenTimeout
        if count < retries
          count += 1
          retry
        else
          { error: "no response (timeout) from URL: #{url}"  }
        end
      end
    end

    # In PowerSchool go to System>System Settings>Plugin Management Configuration>your plugin>Data Provider Configuration to manually check plugin expiration date
    def authenticate
      @headers[:headers] ||= {}
      ps_url   = base_uri + auth_path
      # ps_url = credentials[:base_uri] + credentials[:auth_endpoint]
      response = HTTParty.post(ps_url, {headers: auth_headers,
                                        body: 'grant_type=client_credentials'})

      @credentials[:token_expires] = Time.now + response.parsed_response['expires_in'].to_i
      @credentials[:access_token]  = response.parsed_response['access_token'].to_s
      @headers[:headers].merge!('Authorization' => 'Bearer ' + credentials[:access_token])

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

    def auth_headers(creds64 = encode_credentials)
      { 'ContentType' => 'application/x-www-form-urlencoded;charset=UTF-8',
        'Accept' => 'application/json',
        'Authorization' => 'Basic ' + creds64
      }
    end

    def encode_credentials(creds = credentials)
      ps_auth_text = [ creds[:client_id],
                       creds[:client_secret]
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

    def header_defaults
      { headers:
        { 'User-Agent' => "PsUtilitiesGem - v#{PsUtilities::Version::VERSION}",
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'}
      }
    end

  end
end
