require "spec_helper"

RSpec.describe PsUtilities::Connection do

  let!(:ps)       { PsUtilities::Connection.new }
  let(:base_path) { "#{ENV['PS_BASE_URI']}"}
  let(:credentials) {
    { client_id: ENV['PS_CLIENT_ID'],
      client_secret: ENV['PS_CLIENT_SECRET']
    }
  }
  let(:auth_headers){
    { 'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8',
      'Accept' => 'application/json',
      'Authorization' => "Basic #{ps.send(:encode64_client, credentials)}"}
  }
  let(:auth_token){ "addsfabe-adds-4444-bbbb-444411ffffbb" }
  let(:authorize_return) {
    { 'access_token' => "#{auth_token}",
      'token_type' => "Bearer",
      'expires_in' => "2504956"
    }
  }
  let(:headers)   {
    { 'User-Agent' => "PsUtilities - #{ps.version}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{auth_token}"
    }
  }
  let(:t1_enrolled){
    {"students"=>
      { "@expansions"=>"demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
        "@extensions"=> "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
        "student"=> [
          { "id"=>5851,
            "local_id"=>114679,
            "student_username"=>"takik123",
            "name"=>{"first_name"=>"Ken", "last_name"=>"TAKI"}
          },
          { "id"=>7324,
            "local_id"=>565869,
            "student_username"=>"tirab456",
            "name"=>{"first_name"=>"Best", "last_name"=>"TIRA BALL"}
          }
        ]
      }
    }
  }

  context "version test" do
    it "displays correct gem version" do
      # ps  = PsUtilities::Connection.new
      expect( ps.version ).to match( PsUtilities::Version::VERSION )
    end
  end

  context "PowerSchool Auth Tests" do

    it "authenicates get authorization token" do
      stub_request(:post, "#{ENV['PS_BASE_URI']}/oauth/access_token").
        with(headers: auth_headers, body: 'grant_type=client_credentials').
        to_return(body: authorize_return.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      answer  = ps.run(command: :authenticate)
      expect(answer['access_token']).to  eq(auth_token)
    end
    it "authenicates to set a expiration time" do
      stub_request(:post, "#{ENV['PS_BASE_URI']}/oauth/access_token").
        with(headers: auth_headers, body: 'grant_type=client_credentials').
        to_return(body: authorize_return.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      answer  = ps.run(command: :authenticate)
      expect(answer['token_expires']).to be > Time.now
    end
    it "authenicates is the default command" do
      stub_request(:post, "#{ENV['PS_BASE_URI']}/oauth/access_token").
        with(headers: auth_headers, body: 'grant_type=client_credentials').
        to_return(body: authorize_return.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      expect { ps.run }.not_to raise_error()
    end
    it "bad connection throws auth error" do
      stub_request(:post, "#{ENV['PS_BASE_URI']}/oauth/access_token").
        with(headers: auth_headers, body: 'grant_type=client_credentials').
        to_return(status: 404,
                  headers: { 'Content-Type' => 'application/json' })
      expect { ps.run }.to raise_error(AuthError, /No Auth Token Returned/)
    end
  end

  context "PowerSchool api send / return success" do
    it "run(command: :xxxx) return expected data type" do
      stub_request(:post, "#{ENV['PS_BASE_URI']}/oauth/access_token").
        with(headers: auth_headers, body: 'grant_type=client_credentials').
        to_return(body: authorize_return.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      stub_request(:get,
        "#{ENV['PS_BASE_URI']}/ws/v1/district/student?page=1&pagesize=2&q=school_enrollment.enroll_status_code==0;student_username==t*").
        with(headers: headers).
        to_return(body: t1_enrolled.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      # ps.run(command: :authenticate)
      answer  = ps.run(command: :get,
                        api_path: "/ws/v1/district/student?page=1&pagesize=2&q=school_enrollment.enroll_status_code==0;student_username==t*"
                       )
      correct = t1_enrolled
      expect( answer.parsed_response ).to eq( correct )
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

  # UNIT TESTS
  context "auth_valid? " do
    it "detects a valid auth_token" do
      # ps_new    = PsUtilities::Connection.new
      auth_info = {'access_token' => 'not-bad', 'token_expires' => Time.now+100}
      answer    = ps.send(:auth_valid?, auth_info)
      expect( answer ).to be true
    end
    it "detects a nil time token" do
      # ps_new    = PsUtilities::Connection.new
      auth_info = {'access_token' => 'not-bad', 'token_expires' => nil}
      answer    = ps.send(:auth_valid?, auth_info)
      expect( answer ).to be_falsey
    end
    it "detects an expired token" do
      ps_new    = PsUtilities::Connection.new
      auth_info = {'access_token' => 'not-bad', 'token_expires' => Time.now-10000}
      answer    = ps_new.send(:auth_valid?, auth_info)
      expect( answer ).to be_falsey
    end
    it "detects an blank token" do
      # ps_new = PsUtilities::Connection.new
      auth_info = {'access_token' => '', 'token_expires' => Time.now+1000}
      answer = ps.send(:auth_valid?, auth_info)
      expect( answer ).to be_falsey
    end
    it "detects an nil token" do
      # ps_new    = PsUtilities::Connection.new
      auth_info = {'access_token' => nil, 'token_expires' => Time.now+10000}
      answer    = ps.send(:auth_valid?, auth_info)
      expect( answer ).to be_falsey
    end
  end

  context "create auth header"  do
    it "encodes username and password - encode64_client" do
      # ps_new    = PsUtilities::Connection.new
      client  = {client_id: "MyName", client_secret: "ClientSecret"}
      answer  = ps.send(:encode64_client, client)
      correct = "TXlOYW1lOkNsaWVudFNlY3JldA=="
      expect(answer).to eq(correct)
    end
    it "creates the auth header" do
      # ps    = PsUtilities::Connection.new
      client  = {client_id: "MyName", client_secret: "ClientSecret"}
      answer  = ps.send(:auth_headers, client)
      correct = {
        "Content-Type"=>"application/x-www-form-urlencoded;charset=UTF-8",
        "Accept"=>"application/json",
        "Authorization"=>"Basic TXlOYW1lOkNsaWVudFNlY3JldA=="
      }
      expect(answer).to eq(correct)
    end
  end

end
