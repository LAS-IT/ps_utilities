require "spec_helper"

RSpec.describe PsUtilities::Connection do

  context "server parameters are correct" do
    it "shows correct base_uri from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_URL' => 'ps_url'))
      ps = PsUtilities::Connection.new({attributes: {base_uri: 'params_host'}})
      expect(ps.credentials[:base_uri]).to eq('params_host')
    end
    it "shows correct base_uri from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_URL' => 'ps_url'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:base_uri]).to eq(ENV['PS_URL'])
    end
    it "shows correct auth_endpoint from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_ATUH_ENDPOINT' => 'auth_endpoint'))
      ps = PsUtilities::Connection.new({attributes: {auth_endpoint: 'endpoint'}})
      expect(ps.credentials[:auth_endpoint]).to eq('endpoint')
    end
    it "shows correct auth_endpoint from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_AUTH_ENDPOINT' => 'auth_endpoint'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:auth_endpoint]).to eq(ENV['PS_AUTH_ENDPOINT'])
    end
    it "shows correct client_id from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      ps = PsUtilities::Connection.new({attributes: {client_id: 'id'}})
      expect(ps.credentials[:client_id]).to eq('id')
    end
    it "shows correct client_id from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:client_id]).to eq(ENV['PS_CLIENT_ID'])
    end
    it "shows correct client_secret from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      ps = PsUtilities::Connection.new({attributes: {client_secret: 'secret'}})
      expect(ps.credentials[:client_secret]).to eq('secret')
    end
    it "shows correct client_secret from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:client_secret]).to eq(ENV['PS_CLIENT_SECRET'])
    end
    it "shows correct access_token from parameters" do
      stub_const('ENV', ENV.to_hash.merge('PS_ACCESS_TOKEN' => 'access_token'))
      ps = PsUtilities::Connection.new({attributes: {access_token: 'token'}})
      expect(ps.credentials[:access_token]).to eq('token')
    end
    it "shows correct access_token from environment" do
      stub_const('ENV', ENV.to_hash.merge('PS_ACCESS_TOKEN' => 'access_token'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:access_token]).to eq(ENV['PS_ACCESS_TOKEN'])
    end
  end

  context "server parameters are not correct" do
    it "errors when ps_url is missing" do
      stub_const('ENV', ENV.to_hash.merge('PS_URL' => nil))
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

  context "PowerSchool connection" do
    it "builds a connection to PowerSchool" do
      expect { PsUtilities::Connection.new }.not_to raise_error()
    end
    it "authenticates to PowerSchool" do
      ps = PsUtilities::Connection.new
      expect { ps.run }.not_to raise_error()
      # ps = PsUtilities::Connection.new
      # response = ps.run
      # not to raise error - eventually you will want data
      # expect(response).to be_truthy
    end
    it ""
  end
end

# @credentials=
#   {:base_uri=>"https://las-test.powerschool.com",
#    :auth_endpoint=>"/oauth/access_token",
#    :client_id=>"99702fda-963e-4494-9276-94dfca726669",
#    :client_secret=>"1c6ba14b-e19d-498c-b930-404932702c57",
#    :access_token=>nil},
#    @options={:headers=>{"User-Agent"=>"Ruby Powerschool",
#      "Accept"=>"application/json",
#      "Content-Type"=>"application/json"}}
