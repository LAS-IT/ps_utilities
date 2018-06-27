require "spec_helper"

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe PsUtilities::PreBuiltGet do

  let!(:ps)       { PsUtilities::Connection.new }
  let(:base_path) { "#{ENV['PS_URL']}"}
  let(:auth_token){ "1234567890" }
  let(:headers)   { { 'User-Agent' => "PsUtilities - #{ps.version}",
                      'Accept' => 'application/json',
                      'Content-Type' => 'application/json',
                      # 'Authorization' => "Bearer #{auth_token}"
                  } }

  context "student get commmands" do
    it "count active students" do
      stub_request(:get,
        "#{base_path}/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0").
        with(headers: headers).
        to_return(body: {resource: {count: 423}}.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      count = ps.send(:get_matching_students_count, {status_code: 0})
      expect(count).to be 423
    end
    xit "can search students" do

    end
    xit "can query all active students" do

    end
    xit "can query one students" do

    end
  end

end
