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

  class Connection

    attr_reader :auth_path, :auth_token, :auth_info, :headers
    attr_reader :api_data, :base_uri, :auth_path
    attr_reader :client, :client_id, :client_secret
    attr_reader :version

    include PsUtilities::PreBuiltGet
    include PsUtilities::PreBuiltPut
    include PsUtilities::PreBuiltPost

    # @param attributes: [Hash] -  options include: { base_uri: ENV['PS_BASE_URL'], auth_endpoint: (ENV['PS_AUTH_ENDPOINT'] || '/oauth/access_token'), client_id: ENV['PS_CLIENT_ID'], client_secret: ENV['PS_CLIENT_SECRET'] }
    # @param headers: [Hash] - allows to change from json to xml (only do this if you are doing direct api calls and not using pre-built calls) returns and use a different useragent: { 'User-Agent' => "PsUtilities - #{version}", 'Accept' => 'application/json', 'Content-Type' => 'application/json'}
    # @note preference is to use environment variables to initialize your server.
    def initialize( header_info: {}, api_info: {}, client_info: {})
      @version       = "v#{PsUtilities::Version::VERSION}"
      @client        = client_defaults.merge(client_info)
      @client_id     = client[:client_id]
      @client_secret = client[:client_secret]
      @api_data      = api_defaults.merge(api_info)
      @base_uri      = api_data[:base_uri]
      @auth_path     = api_data[:auth_endpoint]
      @headers       = header_defaults.merge(header_info)

      raise ArgumentError, "missing client_secret" if client_secret.nil? or client_secret.empty?
      raise ArgumentError, "missing client_id"     if client_id.nil? or client_id.empty?
      raise ArgumentError, "missing auth endpoint" if auth_path.nil? or auth_path.empty?
      raise ArgumentError, "missing base_uri"      if base_uri.nil? or base_uri.empty?
    end

    # this runs the various options:
    # @param command: [Symbol] - commands include direct api calls: :authenticate, :delete, :get, :patch, :post, :put (these require api_path: and options: params) & also pre-built commands - see included methods (they require params:)
    # @param api_path: [String] - this is the api_endpoint (only needed for direct api calls)
    # @param options: [Hash] - this is the data body or the query options (needed for direct api calls)
    # @param params: [Hash] - this is the data needed for using pre-built commands - see the individual command for details
    # @note with no command an authenticatation check is done
    def run(command: nil, api_path: "", options: {}, params: {})
      authenticate                            unless auth_valid?

      case command
      when nil, :authenticate
        authenticate
      when :delete, :get, :patch, :post, :put
        api(command, api_path, options)       unless api_path.empty?
        # TODO: panick if api_path empty
      else
        send(command, params)
      end
    end

    private

    def authorized_token
      "#{auth_info['access_token']}"
    end

    # verb = :delete, :get, :patch, :post, :put
    # options = {query: {}, body: {}} - get uses :query, put and post use :body
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

    def header_defaults
      { headers:
        { 'User-Agent' => "PsUtilities - #{version}",
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      }
    end

    # In PowerSchool go to System>System Settings>Plugin Management Configuration>your plugin>Data Provider Configuration to manually check plugin expiration date
    def authenticate
      ps_url   = base_uri + auth_path
      response = HTTParty.post(ps_url, {headers: auth_headers,
                                        body: 'grant_type=client_credentials'})
      if response.code.to_s.eql? "200"
        @auth_info = response.parsed_response
        @auth_info['token_expires'] = Time.now + response.parsed_response['expires_in'].to_i
        @headers[:headers].merge!('Authorization' => 'Bearer ' + auth_info['access_token'])
        return auth_info
      else
        # throw error if - error returned -- nothing else will work
        raise AuthError.new("No Auth Token Returned", ps_url, client )
      end
    end

    def auth_valid?(auth = auth_info)
      return false if auth.nil?
      return false if auth.empty?
      return false if auth['access_token'].nil?
      return false if auth['access_token'].empty?
      return false if auth['token_expires'].nil?
      return false if auth['token_expires'] < Time.now
      return true
    end

    def auth_headers(credentials = client)
      { 'ContentType' => 'application/x-www-form-urlencoded;charset=UTF-8',
        'Accept' => 'application/json',
        'Authorization' => 'Basic ' + encode64_client(credentials)
      }
      # with(headers: {'Authorization' => "Basic #{ Base64.strict_encode64('user:pass').chomp}"})
    end

    def encode64_client(credentials = client)
      ps_auth_text = [ credentials[:client_id], credentials[:client_secret] ].join(':')
      Base64.encode64(ps_auth_text).chomp
      # Base64.encode64(ps_auth_text).gsub(/\n/, '')
    end

    def client_defaults
      { client_id:      ENV['PS_CLIENT_ID'],
        client_secret:  ENV['PS_CLIENT_SECRET'],
      }
    end

    def api_defaults
      { base_uri:       ENV['PS_BASE_URL'],
        auth_endpoint:  ENV['PS_AUTH_ENDPOINT'] || '/oauth/access_token',
      }
    end

  end
end
