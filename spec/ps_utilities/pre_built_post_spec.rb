require "spec_helper"

RSpec.describe PsUtilities::PreBuiltPost do

  let!(:ps)       { PsUtilities::Connection.new }
  let(:base_path) { "#{ENV['PS_URL']}"}
  # let(:auth_token){ "1234567890" }
  let(:headers)   {
    { 'User-Agent' => "PsUtilities - #{ps.version}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      # 'Authorization' => "Bearer #{auth_token}"
    }
  }
  # required fields on creation (student_id/local_id - optional/recommended)
  let(:create_kid) {
    # {student:
      { student_id: 555807,
        last_name: "LAST1", first_name: "First1",
        grade_level: 7, school_number: 11,
        entry_date: "2018-01-07", exit_date: "2018-06-30"
      }
    # }
  }
  let(:create_kids) {
      [
        { student_id: 555807,
          last_name: "LAST1", first_name: "First1",
          grade_level: 7, school_number: 11,
          entry_date: "2018-01-07", exit_date: "2018-06-30"
        },
        { student_id: 555808, last_name: "LAST2", first_name: "Second2",
          email: "second2@las.ch", grade_level: 11, entry_date: "2018-01-07",
          exit_date: "2018-06-30", school_number: 33,
          status_code: 0, home_room: "Valley View", next_school: 33, sched_next_year_grade: 12,
          gender: "F", birth_date: "1990-05-15", projected_graduation_year: 2019,
          u_students_extension: { student_email: "second2@las.ch", preferredname: "Secondly"},
          u_studentsuserfields: { transcriptaddrline1: "Chemin de la Source 3",
                                  transcriptaddrzip: "1854", transcriptaddrstate: "VD",
                                  transcriptaddrcity: "Leysin", transcriptaddrcountry: "CH"}
        }
      ]
  }
  let(:ans_create_1)  {
    {"results"=>
      {"insert_count"=>1,
       "update_count"=>0,
       "delete_count"=>0,
       "result"=>
        {"client_uid"=>555807,
         "status"=>"SUCCESS",
         "action"=>"INSERT",
         "success_message"=>
          {"id"=>7337,
           "ref"=>"https://las-test.powerschool.com/ws/v1/student/7337"}}}}
  }
  let(:ans_create_2)  {
    {"results"=>
      {"insert_count"=>2,
       "update_count"=>0,
       "delete_count"=>0,
       "result"=> [
          { "client_uid"=>555807, "status"=>"SUCCESS", "action"=>"INSERT",
            "success_message"=>{"id"=>7337, "ref"=>"https://las-test.powerschool.com/ws/v1/student/7337"}
          },
          { "client_uid"=>555808, "status"=>"SUCCESS", "action"=>"INSERT",
            "success_message"=>{"id"=>7338, "ref"=>"https://las-test.powerschool.com/ws/v1/student/7338"}
          }

        ]
      }
    }
  }
  let(:update_kid) {
      {
        id: 7337, student_id: 555807, email: "joey@las.ch", middle_name: "Middle",
      }
  }
  let(:update_kids) {
      [
        { id: 7337, student_id: 555807, email: "joey@las.ch",
          u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
          u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                                  transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                                  transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
        },
        { id: 7338, student_id: 555808, email: "jack@las.ch",
          u_students_extension: { student_email: "jack@las.ch", preferredname: "jack"},
          u_studentsuserfields: { transcriptaddrline1: "A Rd.",
                                  transcriptaddrzip: "1859", transcriptaddrstate: "VD",
                                  transcriptaddrcity: "Aigle",transcriptaddrcountry: "DE"}
        }
      ]
  }
  let(:ans_update_1)  {
    {"results"=>
      {"insert_count"=>0,
       "update_count"=>1,
       "delete_count"=>0,
       "result"=>
        {"client_uid"=>555807, "status"=>"SUCCESS", "action"=>"UPDATE", "success_message"=>{"id"=>7337, "ref"=>"https://las-test.powerschool.com/ws/v1/student/7337"}}}}
  }
  let(:ans_update_2)  {
    {"results"=>
      {"insert_count"=>0,
       "update_count"=>2,
       "delete_count"=>0,
       "result"=> [
          { "client_uid"=>555807, "status"=>"SUCCESS", "action"=>"UPDATE",
            "success_message"=>{"id"=>7337, "ref"=>"https://las-test.powerschool.com/ws/v1/student/7337"}
          },
          { "client_uid"=>555808, "status"=>"SUCCESS", "action"=>"UPDATE",
            "success_message"=>{"id"=>7338, "ref"=>"https://las-test.powerschool.com/ws/v1/student/7338"}
          }

        ]
      }
    }
  }

  context "PUBLIC create Student" do
    it "create one student" do
      # Mocks
      array   = ps.send(:build_kids_api_array, "INSERT", {students: [create_kid]})
      body    = { students: { student: array } }.to_json
      stub_request(:post,
        "#{base_path}/ws/v1/student").
        with(     headers: headers, body: body).
        to_return(body: ans_create_1.to_json, status: 200,
                  headers: {'Content-Type' => 'application/json'})
      # Test
      answer  = ps.send( :create_student, {students: [create_kid]} )
      correct = ans_create_1
      expect(answer).to eq(correct)
    end
    it "create multiple students" do
      # Mocks
      array   = ps.send(:build_kids_api_array, "INSERT", {students: create_kids})
      body    = { students: { student: array } }.to_json
      stub_request(:post,
        "#{base_path}/ws/v1/student").
        with(     headers: headers, body: body).
        to_return(body: ans_create_2.to_json, status: 200,
                  headers: {'Content-Type' => 'application/json'})
      # Test
      answer  = ps.send( :create_student, {students: create_kids} )
      correct = ans_create_2
      expect(answer).to eq(correct)
    end
  end
  context "PUBLIC update Student" do
    it "update student" do
      # Mocks
      array   = ps.send(:build_kids_api_array, "UPDATE", {students: [update_kid]})
      body    = { students: { student: array } }.to_json
      stub_request(:post,
        "#{base_path}/ws/v1/student").
        with(     headers: headers, body: body).
        to_return(body: ans_update_1.to_json, status: 200,
                  headers: {'Content-Type' => 'application/json'})
      # TEST
      answer  = ps.send( :update_student, {students: [update_kid]} )
      correct = ans_update_1
      expect(answer).to eq(correct)
    end
    it "update students" do
      # MOCKS
      array   = ps.send(:build_kids_api_array, "UPDATE", {students: update_kids})
      body    = { students: { student: array } }.to_json
      stub_request(:post,
        "#{base_path}/ws/v1/student").
        with(headers: headers, body: body).
        to_return(body: ans_update_2.to_json, status: 200,
                  headers: { 'Content-Type' => 'application/json' })
      # TEST
      answer  = ps.send( :update_students, {students: update_kids} )
      correct = ans_update_2
      expect(answer).to eq(correct)
    end
  end
  # test test are only helpful for debugging
  context "PRIVATE methods - for debugging" do
    it "build_kid_attributes" do
      answer  = ps.send(:build_kid_attributes, "UPDATE", update_kid)
      # pp answer
      correct = { :action=>"UPDATE", :id=>7337, :client_uid=>"555807",
                  :name=>{:middle_name=>"Middle"},
                  :contact_info=>{:email=>"joey@las.ch"}}
      expect(answer).to eq(correct)
    end
    it "build_kids_api_array - 1 kid" do
      answer  = ps.send(:build_kids_api_array, "UPDATE", {students: [update_kid]})
      correct = [{:action=>"UPDATE",
                  :id=>7337,
                  :client_uid=>"555807",
                  :name=>{:middle_name=>"Middle"},
                  :contact_info=>{:email=>"joey@las.ch"}}]
      expect(answer).to eq(correct)
    end
    it "build_kids_api_array - 2 kids" do
      answer  = ps.send(:build_kids_api_array, "UPDATE", {students: update_kids})
      correct = [{:action=>"UPDATE",
                  :id=>7337,
                  :client_uid=>"555807",
                  :contact_info=>{:email=>"joey@las.ch"},
                  "_extension_data"=>
                   {"_table_extension"=>
                     [{"name"=>"u_studentsuserfields",
                       "recordFound"=>false,
                       "_field"=>
                        [{"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"LAS"},
                         {"name"=>"transcriptaddrline2", "type"=>"String", "value"=>"CP 108"},
                         {"name"=>"transcriptaddrzip", "type"=>"String", "value"=>"1858"},
                         {"name"=>"transcriptaddrstate", "type"=>"String", "value"=>"VD"},
                         {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"Bex"},
                         {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"CH"}]},
                      {"name"=>"u_students_extension",
                       "recordFound"=>false,
                       "_field"=>
                        [{"name"=>"student_email", "type"=>"String", "value"=>"joey@las.ch"},
                         {"name"=>"preferredname", "type"=>"String", "value"=>"Joey"}]}]}},
                 {:action=>"UPDATE",
                  :id=>7338,
                  :client_uid=>"555808",
                  :contact_info=>{:email=>"jack@las.ch"},
                  "_extension_data"=>
                   {"_table_extension"=>
                     [{"name"=>"u_studentsuserfields",
                       "recordFound"=>false,
                       "_field"=>
                        [{"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"A Rd."},
                         {"name"=>"transcriptaddrzip", "type"=>"String", "value"=>"1859"},
                         {"name"=>"transcriptaddrstate", "type"=>"String", "value"=>"VD"},
                         {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"Aigle"},
                         {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"DE"}]},
                      {"name"=>"u_students_extension",
                       "recordFound"=>false,
                       "_field"=>
                        [{"name"=>"student_email", "type"=>"String", "value"=>"jack@las.ch"},
                         {"name"=>"preferredname", "type"=>"String", "value"=>"jack"}]}]}}]
      expect(answer).to eq(correct)
    end
    it "build u_students_extension" do
      answer  = ps.send(:u_students_extension, update_kids[0][:u_students_extension])
      correct = {"name"=>"u_students_extension",
                 "recordFound"=>false,
                 "_field"=>
                  [{"name"=>"student_email", "type"=>"String", "value"=>"joey@las.ch"},
                   {"name"=>"preferredname", "type"=>"String", "value"=>"Joey"}
                  ]
                }
      expect(answer).to eq(correct)
    end
    it "build u_studentsuserfields" do
      answer  = ps.send(:u_studentsuserfields, update_kids[0][:u_studentsuserfields])
      correct = {"name"=>"u_studentsuserfields",
                 "recordFound"=>false,
                 "_field"=>
                  [{"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"LAS"},
                   {"name"=>"transcriptaddrline2", "type"=>"String", "value"=>"CP 108"},
                   {"name"=>"transcriptaddrzip", "type"=>"String", "value"=>"1858"},
                   {"name"=>"transcriptaddrstate", "type"=>"String", "value"=>"VD"},
                   {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"Bex"},
                   {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"CH"}
                  ]
                }
      expect(answer).to eq(correct)
    end
  end

end
