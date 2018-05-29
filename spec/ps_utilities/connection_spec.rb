require "spec_helper"

RSpec.describe PsUtilities::Connection do

  context "server parameters are correct" do
    it "shows correct base_uri from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_URL' => 'ps_url'))
      ps = PsUtilities::Connection.new({credentials: {base_uri: 'params_host'}})
      expect(ps.api_credentials[:base_uri]).to eq('params_host')
    end
    it "shows correct base_uri from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_URL' => 'ps_url'))
      ps = PsUtilities::Connection.new
      expect(ps.api_credentials[:base_uri]).to eq(ENV['PS_URL'])
    end
    it "shows correct auth_endpoint from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_ATUH_ENDPOINT' => 'auth_endpoint'))
      ps = PsUtilities::Connection.new({credentials: {auth_endpoint: 'endpoint'}})
      expect(ps.api_credentials[:auth_endpoint]).to eq('endpoint')
    end
    it "shows correct auth_endpoint from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_ATUH_ENDPOINT' => 'auth_endpoint'))
      ps = PsUtilities::Connection.new
      expect(ps.api_credentials[:auth_endpoint]).to eq(ENV['PS_AUTH_ENDPOINT'])
    end
    it "shows correct client_id from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      ps = PsUtilities::Connection.new({credentials: {client_id: 'id'}})
      expect(ps.api_credentials[:client_id]).to eq('id')
    end
    it "shows correct client_id from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      ps = PsUtilities::Connection.new
      expect(ps.api_credentials[:client_id]).to eq(ENV['PS_CLIENT_ID'])
    end
    it "shows correct client_secret from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      ps = PsUtilities::Connection.new({credentials: {client_secret: 'secret'}})
      expect(ps.api_credentials[:client_secret]).to eq('secret')
    end
    it "shows correct client_secret from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      ps = PsUtilities::Connection.new
      expect(ps.api_credentials[:client_secret]).to eq(ENV['PS_CLIENT_SECRET'])
    end
    it "shows correct access_token from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_ACCESS_TOKEN' => 'access_token'))
      ps = PsUtilities::Connection.new({credentials: {access_token: 'token'}})
      expect(ps.api_credentials[:access_token]).to eq('token')
    end
    it "shows correct access_token from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_ACCESS_TOKEN' => 'access_token'))
      ps = PsUtilities::Connection.new
      expect(ps.api_credentials[:access_token]).to eq(ENV['PS_ACCESS_TOKEN'])
    end
  end

  context "server parameters are not correct" do
    xit "errors when ps_url is missing" do
      
    end
  end
end
