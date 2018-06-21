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

    attr_reader :credentials, :headers

    include PsUtilities::PreBuiltGet
    include PsUtilities::PreBuiltPut
    include PsUtilities::PreBuiltPost

    def initialize(attributes: {}, headers: {})
      @credentials = attr_defaults.merge(attributes)
      @headers     = header_defaults.merge(headers)

      raise ArgumentError, "missing client_secret" if credentials[:client_secret].nil?  or
                                                      credentials[:client_secret].empty?
      raise ArgumentError, "missing client_id"     if credentials[:client_id].nil?  or
                                                      credentials[:client_id].empty?
      raise ArgumentError, "missing base_uri"      if credentials[:base_uri].nil?  or
                                                      credentials[:base_uri].empty?
    end

    # with no command it just authenticates
    def run(command: nil, params: {}, url: nil, options: {})
      authenticate   unless token_valid?
      case command
      when nil, :authenticate
        # authenticate            unless token_valid?
      when :get, :put, :post
        send(command, url, options) unless url.empty?
      else
        send(command, params)
      end
    end

    private

    # options = {query: {}}
    def get(url, options={})
      max_retries = 3
      times_retried = 0
      options = options.merge(headers)
      ps_url = credentials[:base_uri] + url
      begin
        HTTParty.get(ps_url, options)
        # self.class.get(url, query: options[:query], headers: options[:headers])
      rescue Net::ReadTimeout, Net::OpenTimeout
        if times_retried < max_retries
          times_retried += 1
          retry
        else
          { error: "no response (timeout) from URL: #{url}"  }
        end
      end
    end

    # options = {body: {}}
    def put(url, options={})
      max_retries = 3
      times_retried = 0
      options = options.merge(headers)
      ps_url = credentials[:base_uri] + url
      begin
        HTTParty.put(ps_url, options )
        # self.class.get(url, body: options[:body], headers: options[:headers])
      rescue Net::ReadTimeout, Net::OpenTimeout
        if times_retried < max_retries
          times_retried += 1
          retry
        else
          { error: "no response (timeout) from URL: #{url}"  }
        end
      end
    end

    # options = {body: {}}
    def post(url, options={})
      max_retries = 3
      times_retried = 0
      options = options.merge(headers)
      ps_url = credentials[:base_uri] + url
      begin
        HTTParty.post(ps_url, options )
        # self.class.get(url, body: options[:body], headers: options[:headers])
      rescue Net::ReadTimeout, Net::OpenTimeout
        if times_retried < max_retries
          times_retried += 1
          retry
        else
          { error: "no response (timeout) from URL: #{url}"  }
        end
      end
    end

    # In PowerSchool go to System>System Settings>Plugin Management Configuration>your plugin>Data Provider Configuration to manually check plugin expiration date
    def authenticate
      @headers[:headers] ||= {}
      ps_url = credentials[:base_uri] + credentials[:auth_endpoint]
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

    def header_defaults
      { headers:
        { 'User-Agent' => "PsUtilitiesGem - v#{PsUtilities::Version::VERSION}",
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'}
      }
    end

  end
end
