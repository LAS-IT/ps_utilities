require "spec_helper"

RSpec.describe PsUtilities::PreBuiltGet do

  let!(:ps)       { PsUtilities::Connection.new }
  let(:base_path) { "#{ENV['PS_BASE_URI']}"}
  # let(:auth_token){ "1234567890" }
  let(:headers)   {
    { 'User-Agent' => "PsUtilities - #{ps.version}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      # 'Authorization' => "Bearer #{auth_token}"
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
  let(:t2_enrolled){
    {"students"=>
      {"@expansions"=> "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
       "@extensions"=> "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
       "student"=> [
         {"id"=>6016,
          "local_id"=>114369,
          "student_username"=>"treer789",
          "name"=>{"first_name"=>"Richard", "middle_name"=>"Ernest", "last_name"=>"TREE"}
         },
         {"id"=>6128,
          "local_id"=>114978,
          "student_username"=>"trucka978",
          "name"=>{"first_name"=>"Alissa", "last_name"=>"TRUCK"}
         }
       ]
      }
    }
  }
  let(:t_all_enrolled){
    { students:
      [
        { "id"=>5851,
          "local_id"=>114679,
          "student_username"=>"takik123",
          "name"=>{"first_name"=>"Ken", "last_name"=>"TAKI"}
        },
        { "id"=>7324,
          "local_id"=>565869,
          "student_username"=>"tirab456",
          "name"=>{"first_name"=>"Best", "last_name"=>"TIRA BALL"}
        },
        {"id"=>6016,
         "local_id"=>114369,
         "student_username"=>"treer789",
         "name"=>{"first_name"=>"Richard", "middle_name"=>"Ernest", "last_name"=>"TREE"}
        },
        {"id"=>6128,
         "local_id"=>114978,
         "student_username"=>"trucka978",
         "name"=>{"first_name"=>"Alissa", "last_name"=>"TRUCK"}
        }
      ]
    }
  }
  let(:kid5851)  {
    {:student=>
      {"@expansions"=>"demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
       "@extensions"=>"s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
       "_extension_data"=>
        {"_table_extension"=>
          {"recordFound"=>false,
           "_field"=>
            [{"name"=>"transcriptaddrzip", "type"=>"String", "value"=>"1854"},
             {"name"=>"grad_day_date_year", "type"=>"String", "value"=>"June 2020"},
             {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"CH"},
             {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"Leysin"},
             {"name"=>"father_name", "type"=>"String", "value"=>"TAKA, Ken"},
             {"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"Chemin de la Source 3"}],
           "name"=>"u_studentsuserfields"}},
       "id"=>5851,
       "local_id"=>114679,
       "student_username"=>"takak123",
       "name"=>{"first_name"=>"Ken", "last_name"=>"TAKA"},
       "demographics"=>{"gender"=>"M", "birth_date"=>"1995-09-02", "projected_graduation_year"=>2020},
       "addresses"=>"",
       "alerts"=>"",
       "phones"=>{"main"=>{"number"=>"+41 79 555 6666"}},
       "school_enrollment"=>
        {"enroll_status"=>"A",
         "enroll_status_description"=>"Active",
         "enroll_status_code"=>0,
         "grade_level"=>10,
         "entry_date"=>"2016-08-20",
         "exit_date"=>"2020-06-09",
         "school_number"=>33,
         "school_id"=>6,
         "entry_comment"=>"Promote Same School",
         "full_time_equivalency"=>{"fteid"=>1070, "name"=>"FTE Value: 1"}},
       "ethnicity_race"=>{"federal_ethnicity"=>"NO"},
       "contact"=>{"guardian_email"=>"kent@fake.com", "father"=>"TAKA, John"},
       "contact_info"=>{"email"=>"takak123@las.ch"},
       "initial_enrollment"=>{"district_entry_grade_level"=>0, "school_entry_grade_level"=>0},
       "schedule_setup"=>{"home_room"=>"Savoy", "next_school"=>999999, "sched_next_year_grade"=>99},
       "fees"=>"",
       "lunch"=>{"balance_1"=>"0.00", "balance_2"=>"0.00", "balance_3"=>"0.00", "balance_4"=>"0.00", "lunch_id"=>0}}}
  }

  context "Important Public TESTS" do
    it "can recursively search students" do
      stub_request(:get,
        "#{base_path}/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0;student_username==t*").
        with(headers: headers).
        to_return(body: {resource: {count: 4}}.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      stub_request(:get,
        "#{base_path}/ws/v1/district/student?page=1&pagesize=2&q=school_enrollment.enroll_status_code==0;student_username==t*").
        with(headers: headers).
        to_return(body: t1_enrolled.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      stub_request(:get,
        "#{base_path}/ws/v1/district/student?page=2&pagesize=2&q=school_enrollment.enroll_status_code==0;student_username==t*").
        with(headers: headers).
        to_return(body: t2_enrolled.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      answer  = ps.send( :get_all_matching_students, {status_code: 0, username: "t*", page_size: 2} )
      correct = t_all_enrolled
      expect( answer ).to eq( correct )
    end
    it "can query all active students" do
      stub_request(:get,
        "#{base_path}/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0").
        with(headers: headers).
        to_return(body: {resource: {count: 4}}.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      stub_request(:get,
        "#{base_path}/ws/v1/district/student?page=1&pagesize=2&q=school_enrollment.enroll_status_code==0").
        with(headers: headers).
        to_return(body: t1_enrolled.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      stub_request(:get,
        "#{base_path}/ws/v1/district/student?page=2&pagesize=2&q=school_enrollment.enroll_status_code==0").
        with(headers: headers).
        to_return(body: t2_enrolled.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      answer  = ps.send( :get_all_active_students, {page_size: 2} )
      correct = t_all_enrolled
      expect( answer ).to eq( correct )
    end
    it "can query all active students" do
      stub_request(:get,
        "#{base_path}/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0").
        with(headers: headers).
        to_return(body: {resource: {count: 4}}.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      stub_request(:get,
        "#{base_path}/ws/v1/district/student?page=1&pagesize=2&q=school_enrollment.enroll_status_code==0").
        with(headers: headers).
        to_return(body: t1_enrolled.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      stub_request(:get,
        "#{base_path}/ws/v1/district/student?page=2&pagesize=2&q=school_enrollment.enroll_status_code==0").
        with(headers: headers).
        to_return(body: t2_enrolled.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      answer  = ps.send( :get_all_active_students, {page_size: 2, last_name: "z*"} )
      correct = t_all_enrolled
      expect( answer ).to eq( correct )
    end
  end

  # THESE are only helpful for debugging
  context "PRIVATE unit tests" do
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
        "#{base_path}/ws/v1/district/student?page=1&pagesize=2&q=school_enrollment.enroll_status_code==0;student_username==t*").
        with(headers: headers).
        to_return(body: t1_enrolled.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      answer  = ps.send( :get_matching_students_page, {status_code: 0, username: "t*", page_size: 2} )
      correct = t1_enrolled
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
    it "can query one students" do
      stub_request(:get,
        "#{base_path}/ws/v1/student/5851?expansions=demographics,addresses,alerts,phones,school_enrollment,ethnicity_race,contact,contact_info,initial_enrollment,schedule_setup,fees,lunch&extensions=s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields").
        with(headers: headers).
        to_return(body: kid5851.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      answer  = ps.send(:get_student, {id: 5851})
      correct = kid5851
      expect(answer).to eq(correct)
    end
  end

end
