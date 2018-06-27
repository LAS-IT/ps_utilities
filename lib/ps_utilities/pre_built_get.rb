module PsUtilities

  module PreBuiltGet

    # return all active students within the district (special case of #get_all_matching_students) - a recursive search
    # @param params [Hash] - ignored - only included for the api standard
    # @return - (see #get_all_matching_students)
    def get_all_active_students(params={})
      params = {status_code: 0}
      # params[:status_code] = 0
      get_all_matching_students(params)
    end
    alias_method :all_active_students, :get_all_active_students

    # return all students within the district matching the filters are passed in -- this is a Recursive search and will collect all students
    # @param params [Hash] - enter a match criteria in the following format (* are allowed for wildcard matching):
    #     {username: "xxxxx*"} or {local_id: "12345"}
    # or  {enroll_status: "x"} or {status_code: "0"}
    # or  {first_name: "John"} or {last_name: "Br*"}
    # or multiple field match
    #     {status_code: "0", last_name: "Br*"}
    # @return [Hash of an Array of Student Summaries] - see below format
    # {students: [
    #     {"id"=>4916, "local_id"=>112406, "student_username"=>"cccc406", "name"=>{"first_name"=>"Ssssss", "last_name"=>"CCCCC"}},
    #     {"id"=>4932, "local_id"=>112520, "student_username"=>"jjjj520", "name"=>{"first_name"=>"Ppppppp", "last_name"=>"JJJJJJJJ"}},
    #     {"id"=>4969, "local_id"=>112766, "student_username"=>"aaaa766", "name"=>{"first_name"=>"Sssss", "middle_name"=>"Aaaaaaaa", "last_name"=>"Aaaaaaaaaa"}}
    #   ]
    # }
    # @note - the api_path sent to the api call looks like: "/ws/v1/district/student?expansions=school_enrollment,contact&q=enroll_status==A;name.last_name==J*"
    def get_all_matching_students(params)
      params[:page_size] ||= 100
      count    = get_matching_students_count(params)
      pages    = calc_pages(count, params[:page_size])
      answer   = {}
      students = []
      (1..pages).each do |page|
        params[:page_number] = page
        answer    = get_matching_students_page(params)
        students << (answer.dig("students","student") || [])
      end
      # answer["students"]["student"] = students.flatten
      # return answer
      { students: students.flatten }
    end
    alias_method :all_matching_students, :get_all_matching_students

    # retrieves all individual student's details - you must use the DCID !!!
    # @param params [Hash] - use either: {dcid: "12345"} or {id: "12345"}
    # @return [Hash] - in the format of:
    # { :student=>
    #   { "@expansions"=> "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #     "@extensions"=> "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #     "_extension_data"=> {
    #       "_table_extension"=> [
    #         { "recordFound"=>false,
    #           "_field"=> [
    #             {"name"=>"preferredname", "type"=>"String", "value"=>"Guy"},
    #             {"name"=>"student_email", "type"=>"String", "value"=>"guy@las.ch"}
    #           ],
    #           "name"=>"u_students_extension"
    #         },
    #         { "recordFound"=>false,
    #           "_field"=> [
    #             {"name"=>"transcriptaddrzip", "type"=>"String", "value"=>1858},
    #             {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"CH"},
    #             {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"Bex"},
    #             {"name"=>"transcriptaddrstate", "type"=>"String", "value"=>"VD"},
    #             {"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"LAS"},
    #             {"name"=>"transcriptaddrline2", "type"=>"String", "value"=>"CP 108"}
    #           ],
    #           "name"=>"u_studentsuserfields"
    #         }
    #       ]
    #     },
    #     "id"=>7337,
    #     "local_id"=>555807,
    #     "student_username"=>"guy807",
    #     "name"=>{"first_name"=>"Mountain", "last_name"=>"BIV"},
    #     "demographics"=>{"gender"=>"M", "birth_date"=>"2002-08-26", "projected_graduation_year"=>2021},
    #     "addresses"=>"",
    #     "alerts"=>"",
    #     "phones"=>"",
    #     "school_enrollment"=> {
    #       "enroll_status"=>"A",
    #       "enroll_status_description"=>"Active",
    #       "enroll_status_code"=>0,
    #       "grade_level"=>9,
    #       "entry_date"=>"2018-06-22",
    #       "exit_date"=>"2019-08-06",
    #       "school_number"=>2,
    #       "school_id"=>2,
    #       "full_time_equivalency"=>{"fteid"=>970, "name"=>"FTE Admissions"}
    #     },
    #     "ethnicity_race"=>{"federal_ethnicity"=>"NO"},
    #     "contact"=>{"guardian_email"=>"guydad@orchid.ch"},
    #     "contact_info"=>{"email"=>"guy@las.ch"},
    #     "initial_enrollment"=>{"district_entry_grade_level"=>0, "school_entry_grade_level"=>0},
    #     "schedule_setup"=>{"next_school"=>33, "sched_next_year_grade"=>10},
    #     "fees"=>"",
    #     "lunch"=>{"balance_1"=>"0.00", "balance_2"=>"0.00", "balance_3"=>"0.00", "balance_4"=>"0.00", "lunch_id"=>0}
    #   }
    # }
    # @note the data within "u_students_extension" - is unique for each school
    def get_one_student(params)
      # api_path = "/ws/v1/district/student/{dcid}?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
      ps_dcid    = params[:dcid] || params[:dc_id] || params[:id]
      api_path   = "/ws/v1/student/#{ps_dcid.to_i}"
      options    = { query:
                      { "extensions" => "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
                        "expansions" => "demographics,addresses,alerts,phones,school_enrollment,ethnicity_race,contact,contact_info,initial_enrollment,schedule_setup,fees,lunch"
                      }
                    }
      return {"errorMessage"=>{"message"=>"A valid dcid must be entered."}} if "#{ps_dcid.to_i}".eql? "0"

      answer = api(:get, api_path, options)
      { student: (answer["student"] || []) }
    end
    alias_method :get_student, :get_one_student

    # find a student within the district by username:, student_id: (local_id), id: (dcid) - this is NOT a recursive search - when many kids match
    # @param params [Hash] - must be one of the following (* are allowed for wildcard matching): {username: "xxxxx*"} or {student_id: "12345"} or {local_id: "12345"} or {dcid: "654321"} or {id: "654321"}
    # @return [Hash] - with the following format:
    # {:students => [
    #   {"id"=>7337,
    #    "local_id"=>555807,
    #    "student_username"=>"bassivm807",
    #    "name"=>{"first_name"=>"Mountain", "last_name"=>"BASS"},
    #    "demographics"=>{"gender"=>"M", "birth_date"=>"2002-08-26", "projected_graduation_year"=>2021},
    #    "addresses"=>"",
    #    "alerts"=>"",
    #    "phones"=>"",
    #    "school_enrollment"=>
    #     {"enroll_status"=>"A",
    #      "enroll_status_description"=>"Active",
    #      "enroll_status_code"=>0,
    #      "grade_level"=>9,
    #      "entry_date"=>"2018-06-22",
    #      "exit_date"=>"2019-08-06",
    #      "school_number"=>2,
    #      "school_id"=>2,
    #      "full_time_equivalency"=>{"fteid"=>970, "name"=>"FTE Admissions"}},
    #    "ethnicity_race"=>{"federal_ethnicity"=>"NO"},
    #    "contact"=>{"guardian_email"=>"mountain@bass.com"},
    #    "contact_info"=>{"email"=>"joey@las.ch"},
    #    "initial_enrollment"=>{"district_entry_grade_level"=>0, "school_entry_grade_level"=>0},
    #    "schedule_setup"=>{"next_school"=>33, "sched_next_year_grade"=>10},
    #    "fees"=>"",
    #    "lunch"=>{"balance_1"=>"0.00", "balance_2"=>"0.00", "balance_3"=>"0.00", "balance_4"=>"0.00", "lunch_id"=>0}
    #   },
    #   { ... }
    #  ]
    # }
    # @note - this lookup will not include data from database extensions
    # def find_students(params)
    #   # api_path = "/ws/v1/district/student?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
    #   api_path   = "/ws/v1/district/student"
    #
    #   options    = { query: {"expansions" => "demographics,addresses,alerts,phones,school_enrollment,ethnicity_race,contact,contact_info,initial_enrollment,schedule_setup,fees,lunch"} }
    #   query      = build_query(params)
    #   options[:query]["q"] = query.join(";")
    #   return {"errorMessage"=>{"message"=>"A valid parameter must be entered."}} if query.empty?
    #
    #   answer = api(:get, api_path, options)
    #   { students: (answer.dig("students","student") || []) }
    # end
    # alias_method :find_student, :find_students
    # alias_method :find_student_by_local_id, :find_students
    # alias_method :find_student_by_username, :find_students

    private

    # given the number of students and page size calculate pages needed to return all students
    # @param count [Integer] - total number of students matching filter
    # @param page_size [Integer] - total number of students to be return per page
    # For example:
    #     given: page_size = 100
    #     when: 430 kids, then: 5 pages
    #     when: 400 kids, then: 4 pages
    # @return [Integer] - number of pages needed to return all students
    def calc_pages(count, page_size)
      ( (count.to_i-1) / page_size.to_i ).to_i + 1
    end

    # api_path = "/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0"
    # returns: {"resource"=>{"count"=>423}}
    # @return [Integer] - the number of students matching the filter
    def get_matching_students_count(params={})
      api_path = "/ws/v1/district/student/count"

      query   = build_query(params)
      options = {query: { "q" => query } }  unless query.empty?
      return {"errorMessage"=>{"message"=>"A valid parameter must be entered."}} if query.empty?

      answer  = api(:get, api_path, options)  #returns: {"resource"=>{"count"=>423}}
      answer.dig("resource", "count").to_i
    end

    # NOT RECURSIVE - simple call to get one page of student summaries
    # params = {username: "xxxxxxx"} or {local_id: "12345"}
    # or       {enroll_status: "x"} or {status_code: "0"}
    # or       {first_name: "John"} or {last_name: "Brown"}
    # api_path = "/ws/v1/district/student?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
    # @return [Hash] - returns one page of students
    # {"students"=>
    #   {"@expansions"=>
    #     "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #    "@extensions"=>
    #     "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #    "student"=>
    #     [{"id"=>4916, "local_id"=>112406, "student_username"=>"cccc406", "name"=>{"first_name"=>"Ssssss", "last_name"=>"CCCCC"}},
    #      {"id"=>4932,
    #       "local_id"=>112520,
    #       "student_username"=>"jjjjjjjj520",
    #       "name"=>{"first_name"=>"Ppppppp", "last_name"=>"JJJJJJJJ"}},
    #      {"id"=>4969,
    #       "local_id"=>112766,
    #       "student_username"=>"aaaaaaaa766",
    #       "name"=>{"first_name"=>"Sssss", "middle_name"=>"Aaaaaaaa", "last_name"=>"Aaaaaaaaaa"}}
    #     ]
    #   }
    # }
    def get_matching_students_page(params)
      api_path = "/ws/v1/district/student"
      params[:page_size]   ||= 100
      params[:page_number] ||= 1
      # pp params
      options = { query:
                  { "pagesize"    => "#{params[:page_size]}",
                    "page"        => "#{params[:page_number]}"} }
      query    = build_query(params)
      options[:query]["q"] = query     unless query.empty?
      return {"errorMessage"=>{"message"=>"A valid parameter must be entered."}} if query.empty?
      # pp options
      api(:get, api_path, options)
    end

    # build the api query - you can use splats to match any character
    # @param params [Hash] - valid keys include: :status_code (or :enroll_status), :username, :last_name, :first_name, :student_id (or :local_id), :id (or :dcid)
    # @return [String] - "id==345;name.last_name==BA*"
    def build_query(params)
      query  = []
      query << "school_enrollment.enroll_status_code==#{params[:status_code]}" if params.has_key?(:status_code)
      query << "school_enrollment.enroll_status==#{params[:enroll_status]}"    if params.has_key?(:enroll_status)
      query << "student_username==#{params[:username]}"  if params.has_key?(:username)
      query << "name.last_name==#{params[:last_name]}"   if params.has_key?(:last_name)
      query << "name.first_name==#{params[:first_name]}" if params.has_key?(:first_name)
      query << "local_id==#{params[:local_id]}"          if params.has_key?(:local_id)
      query << "local_id==#{params[:student_id]}"        if params.has_key?(:student_id)
      query << "id==#{params[:dcid]}"                    if params.has_key?(:dcid)
      query << "id==#{params[:id]}"                      if params.has_key?(:id)
      answer = query.join(";")
      answer
    end

  end

end
