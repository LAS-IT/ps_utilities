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

    attr_reader :credentials, :headers, :base_uri, :auth_path, :auth_token
    attr_reader :version

    include PsUtilities::PreBuiltGet
    include PsUtilities::PreBuiltPut
    include PsUtilities::PreBuiltPost

    def initialize(attributes: {}, headers: {})
      @version     = "v#{PsUtilities::Version::VERSION}"
      @credentials = attr_defaults.merge(attributes)
      @base_uri    = credentials[:base_uri]
      @auth_path   = credentials[:auth_endpoint]
      @headers     = header_defaults.merge(headers)

      raise ArgumentError, "missing client_secret" if credentials[:client_secret].nil?  or
                                                      credentials[:client_secret].empty?
      raise ArgumentError, "missing client_id"     if credentials[:client_id].nil?  or
                                                      credentials[:client_id].empty?
      raise ArgumentError, "missing base_uri"      if credentials[:base_uri].nil?  or
                                                      credentials[:base_uri].empty?
    end

    # with no command it just checks authenticates if needed
    def run(command: nil, api_path: "", options: {}, params: {})
      authenticate   unless token_valid?
      @headers[:headers].merge!('Authorization' => 'Bearer ' + authorized_token)
      case command
      when nil, :authenticate
      when :delete, :get, :patch, :post, :put
        api(command, api_path, options)         unless api_path.empty?
      else
        send(command, params)
      end
    end

    private

    def authorized_token
      "#{credentials[:access_token]}"
    end

    # verb = :delete, :get, :patch, :post, :put
    # options = {query: {}, body: {}} - get uses :query, put and post use :body
    def api(verb, api_path, options={})
      count   = 0
      retries = 3
      ps_url  = base_uri + api_path
      options = options.merge(headers)
      pp ps_url
      pp options
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

    def header_defaults
      { headers:
        { 'User-Agent' => "PsUtilities - #{version}",
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'}
      }
    end

    # In PowerSchool go to System>System Settings>Plugin Management Configuration>your plugin>Data Provider Configuration to manually check plugin expiration date
    def authenticate
      ps_url   = base_uri + auth_path
      response = HTTParty.post(ps_url, {headers: auth_headers,
                                        body: 'grant_type=client_credentials'})

      @credentials[:token_expires] = Time.now + response.parsed_response['expires_in'].to_i
      @credentials[:access_token]  = response.parsed_response['access_token'].to_s
      # @headers[:headers].merge!('Authorization' => 'Bearer ' + credentials[:access_token])

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
      }
    end

  end
end
