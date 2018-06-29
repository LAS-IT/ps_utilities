require "spec_helper"

RSpec.describe PsUtilities::Connection do

  context "version test" do
    it "displays correct gem version" do
      ps  = PsUtilities::Connection.new
      expect( ps.version ).to match( PsUtilities::Version::VERSION )
    end
  end

  context "server configures with ENV-VARS" do
    it "Instantiates with minimal ENV-VARS" do
      stub_const('ENV', ENV.to_hash.merge('PS_BASE_URI' => 'ps_url'))
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      expect { PsUtilities::Connection.new }.not_to raise_error()
    end
    it "base_uri" do
      stub_const('ENV', ENV.to_hash.merge('PS_BASE_URI' => 'ps_url'))
      ps = PsUtilities::Connection.new
      expect(ps.api_data[:base_uri]).to eq(ENV['PS_BASE_URI'])
    end
    it "auth_endpoint" do
      stub_const('ENV', ENV.to_hash.merge('PS_AUTH_ENDPOINT' => 'auth_endpoint'))
      ps = PsUtilities::Connection.new
      expect(ps.api_data[:auth_endpoint]).to eq(ENV['PS_AUTH_ENDPOINT'])
    end
    it "client_id" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      ps = PsUtilities::Connection.new
      expect(ps.client[:client_id]).to eq(ENV['PS_CLIENT_ID'])
    end
    it "client_secret" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      ps = PsUtilities::Connection.new
      expect(ps.client[:client_secret]).to eq(ENV['PS_CLIENT_SECRET'])
    end
  end

  context "server parameters override ENV-VARS" do
    it "base_uri" do
      stub_const('ENV', ENV.to_hash.merge('PS_BASE_URI' => 'ps_url'))
      ps = PsUtilities::Connection.new(api_info: {base_uri: 'params_host'})
      expect(ps.api_data[:base_uri]).to eq('params_host')
    end
    it "auth_endpoint" do
      stub_const('ENV', ENV.to_hash.merge('PS_ATUH_ENDPOINT' => 'auth_endpoint'))
      ps = PsUtilities::Connection.new(api_info: {auth_endpoint: 'endpoint'})
      expect(ps.api_data[:auth_endpoint]).to eq('endpoint')
    end
    it "client_id" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      ps = PsUtilities::Connection.new(client_info: {client_id: 'id'})
      expect(ps.client[:client_id]).to eq('id')
    end
    it "client_secret" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      ps = PsUtilities::Connection.new(client_info: {client_secret: 'secret'})
      expect(ps.client[:client_secret]).to eq('secret')
    end
    # # OK AS A pass-in param
    # it "access_token" do
    #   # stub_const('ENV', ENV.to_hash.merge('PS_ACCESS_TOKEN' => 'access_token'))
    #   ps = PsUtilities::Connection.new({attributes: {access_token: 'token'}})
    #   expect(ps.api_data[:access_token]).to eq('token')
    # end
  end

  context "server parameters are not correct" do
    it "errors when ps_url is missing" do
      stub_const('ENV', ENV.to_hash.merge('PS_BASE_URI' => nil))
      expect { PsUtilities::Connection.new }.to raise_error(ArgumentError, /missing base_uri/)
    end
    it "errors when client_id is missing" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => nil))
      expect { PsUtilities::Connection.new }.to raise_error(ArgumentError, /missing client_id/)
    end
    it "errors when client_secret is missing" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => nil))
      expect { PsUtilities::Connection.new }.to raise_error(ArgumentError, /missing client_secret/)
    end
  end

  context "auth_valid? " do
    it "detects a valid auth_token" do
      ps_new    = PsUtilities::Connection.new
      auth_info = {'access_token' => 'not-bad', 'token_expires' => Time.now+100}
      answer    = ps_new.send(:auth_valid?, auth_info)
      expect( answer ).to be true
    end
    it "detects a nil time token" do
      ps_new    = PsUtilities::Connection.new
      auth_info = {'access_token' => 'not-bad', 'token_expires' => nil}
      answer    = ps_new.send(:auth_valid?, auth_info)
      expect( answer ).to be_falsey
    end
    it "detects an expired token" do
      ps_new    = PsUtilities::Connection.new
      auth_info = {'access_token' => 'not-bad', 'token_expires' => Time.now-10000}
      answer    = ps_new.send(:auth_valid?, auth_info)
      expect( answer ).to be_falsey
    end
    it "detects an blank token" do
      ps_new = PsUtilities::Connection.new
      auth_info = {'access_token' => '', 'token_expires' => Time.now+1000}
      answer = ps_new.send(:auth_valid?, auth_info)
      expect( answer ).to be_falsey
    end
    it "detects an nil token" do
      ps_new    = PsUtilities::Connection.new
      auth_info = {'access_token' => nil, 'token_expires' => Time.now+10000}
      answer    = ps_new.send(:auth_valid?, auth_info)
      expect( answer ).to be_falsey
    end
  end

  context "create auth header"  do
    it "encodes username and password - encode64_client" do
      ps_new    = PsUtilities::Connection.new
      client  = {client_id: "MyName", client_secret: "ClientSecret"}
      answer  = ps_new.send(:encode64_client, client)
      pp answer
      correct = "TXlOYW1lOkNsaWVudFNlY3JldA=="
      expect(answer).to eq(correct)
    end
    it "creates the auth header" do
      ps_new    = PsUtilities::Connection.new
      client  = {client_id: "MyName", client_secret: "ClientSecret"}
      answer  = ps_new.send(:auth_headers, client)
      correct = {
        "ContentType"=>"application/x-www-form-urlencoded;charset=UTF-8",
        "Accept"=>"application/json",
        "Authorization"=>"Basic TXlOYW1lOkNsaWVudFNlY3JldA=="
      }
      expect(answer).to eq(correct)
    end
  end

end
