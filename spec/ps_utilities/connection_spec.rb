require "spec_helper"

# BEFORE AUTHENTATION
# @credentials=
#  {:base_uri=>"https://las-test.powerschool.com",
#   :auth_endpoint=>"/oauth/access_token",
#   :client_id=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   :client_secret=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"},
# @options=
#  {:headers=>{"User-Agent"=>"Ruby Powerschool", "Accept"=>"application/json", "Content-Type"=>"application/json"}}>

RSpec.describe PsUtilities::Connection do

  context "server configures with ENV-VARS" do
    it "Instantiates with minimal ENV-VARS" do
      stub_const('ENV', ENV.to_hash.merge('PS_URL' => 'ps_url'))
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      expect { PsUtilities::Connection.new }.not_to raise_error()
    end
    it "base_uri" do
      stub_const('ENV', ENV.to_hash.merge('PS_URL' => 'ps_url'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:base_uri]).to eq(ENV['PS_URL'])
    end
    it "auth_endpoint" do
      stub_const('ENV', ENV.to_hash.merge('PS_AUTH_ENDPOINT' => 'auth_endpoint'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:auth_endpoint]).to eq(ENV['PS_AUTH_ENDPOINT'])
    end
    it "client_id" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:client_id]).to eq(ENV['PS_CLIENT_ID'])
    end
    it "client_secret" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:client_secret]).to eq(ENV['PS_CLIENT_SECRET'])
    end
    # not recommended - changes - shouldn't be part of ENV-VARS
    xit "access_token" do
      stub_const('ENV', ENV.to_hash.merge('PS_ACCESS_TOKEN' => 'access_token'))
      ps = PsUtilities::Connection.new
      expect(ps.credentials[:access_token]).to eq(ENV['PS_ACCESS_TOKEN'])
    end
  end

  context "server parameters override ENV-VARS" do
    it "base_uri" do
      stub_const('ENV', ENV.to_hash.merge('PS_URL' => 'ps_url'))
      ps = PsUtilities::Connection.new({attributes: {base_uri: 'params_host'}})
      expect(ps.credentials[:base_uri]).to eq('params_host')
    end
    it "auth_endpoint" do
      stub_const('ENV', ENV.to_hash.merge('PS_ATUH_ENDPOINT' => 'auth_endpoint'))
      ps = PsUtilities::Connection.new({attributes: {auth_endpoint: 'endpoint'}})
      expect(ps.credentials[:auth_endpoint]).to eq('endpoint')
    end
    it "client_id" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'client_id'))
      ps = PsUtilities::Connection.new({attributes: {client_id: 'id'}})
      expect(ps.credentials[:client_id]).to eq('id')
    end
    it "client_secret" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'client_secret'))
      ps = PsUtilities::Connection.new({attributes: {client_secret: 'secret'}})
      expect(ps.credentials[:client_secret]).to eq('secret')
    end
    # OK AS A pass-in param
    it "access_token" do
      # stub_const('ENV', ENV.to_hash.merge('PS_ACCESS_TOKEN' => 'access_token'))
      ps = PsUtilities::Connection.new({attributes: {access_token: 'token'}})
      expect(ps.credentials[:access_token]).to eq('token')
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
