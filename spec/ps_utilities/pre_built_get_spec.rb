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
  let(:t_enroll)  {
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

  context "student unit get" do
    it "calculates pages needed over 100" do
      count = ps.send(:calc_pages, 423, 100)
      expect(count).to be 5
    end
    it "calculates pages needed divisible by 100" do
      count = ps.send(:calc_pages, 400, 100)
      expect(count).to be 4
    end
    it "builds a multi query" do
      params  = {student_id: 1234, username: "th*"}
      answer  = ps.send(:build_query, params)
      correct = "q=local_id==1234;student_username==th*"
    end
    it "builds an empty query" do
      params  = {}
      answer  = ps.send(:build_query, params)
      correct = ""
    end
    it "get_matching_students_page error without search params" do
      answer  = ps.send( :get_matching_students_page, {} )
      correct = {"errorMessage"=>{"message"=>"A valid parameter must be entered."}}
      expect( answer ).to eq( correct )
    end
    it "get_matching_students_page with valid search params" do
      stub_request(:get,
        "#{base_path}/ws/v1/district/student?page=1&pagesize=100&q=school_enrollment.enroll_status_code==0;student_username==t*").
        with(headers: headers).
        to_return(body: t_enroll.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      answer  = ps.send( :get_matching_students_page, {status_code: 0, username: "t*"} )
      correct = t_enroll
      expect( answer ).to eq( correct )
    end
    it "counts active students" do
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
