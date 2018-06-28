require "spec_helper"

# STATE AFTER AUTHENTICATION - notice: token_expires (field)
# @credentials=
#  {:base_uri=>"https://las-test.powerschool.com",
#   :auth_endpoint=>"/oauth/access_token",
#   :client_id=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   :client_secret=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   :token_expires=>2018-02-18 16:47:28 +0200,
#   :access_token=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"},
# @options=
#  {:headers=>
#    {"User-Agent"=>"Ruby Powerschool",
#     "Accept"=>"application/json",
#     "Content-Type"=>"application/json",
#     "Authorization"=>"Bearer xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"}}>

# GET YOUR CONNECTION INFO FROM:
# System>System Settings>Plugin Management Configuration>your plugin>Data_Provider_Configuration

RSpec.describe "Actual Communication Tests" do


  let!(:ps)       { PsUtilities::Connection.new }
  let(:base_path) { "#{ENV['PS_BASE_URL']}"}
  let(:auth_token){ "1234567890" }
  let(:auth_headers){
    { 'ContentType' => 'application/x-www-form-urlencoded;charset=UTF-8',
      'Accept' => 'application/json',
      'Authorization' => 'Basic 1234567890'
    }
  }
  let(:headers)   {
    { 'User-Agent' => "PsUtilities - #{ps.version}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{auth_token}"
    }
  }
  stub_request(:get, "#{base_path}/oauth/access_token").
    with(headers: auth_headers, body: 'grant_type=client_credentials').
    to_return(body: t1_enrolled.to_json, status: 200,
              headers: { 'Content-Type' => 'application/json' })

  context "PowerSchool connection success" do
    it "authenicates by default" do
      ps_new = PsUtilities::Connection.new
      expect { ps_new.run }.not_to raise_error()
    end
    it "authenicates with command" do
      ps_new = PsUtilities::Connection.new
      expect { ps_new.run(command: :authenticate) }.not_to raise_error()
    end
    it "authenticates gets oauth token" do
      ps_new = PsUtilities::Connection.new
      ps_new.run
      answer = ps_new.credentials[:access_token]
      expect( answer ).not_to be nil
    end
    it "authenticates has expiration time" do
      ps_new = PsUtilities::Connection.new
      ps_new.run
      answer = ps_new.credentials[:token_expires]
      expect( answer ).not_to be nil
    end
    xit "run(command: :authenticate) - returns expected data type" do

    end
  end

  context "PowerSchool connection success" do
    it "bad connection throws error" do
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_ID' => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'))
      stub_const('ENV', ENV.to_hash.merge('PS_CLIENT_SECRET' => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'))
      ps_bad = PsUtilities::Connection.new
      # expect { ps_bad.run }.to raise_error(StandardError, /Mickey Mouse/)
      expect { ps_bad.run }.to raise_error(AuthError, /No Auth Token Returned/)
    end
  end

  context "PowerSchool api send / return success" do

    let!(:ps_auth) { PsUtilities::Connection.new.run }

    xit "run(command: :xxxx) return expected data type" do

    end
  end

end
