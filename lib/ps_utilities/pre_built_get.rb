module PsUtilities

  module PreBuiltGet

    def get_all_active_students(params={})
      params[:status_code] = 0
      get_all_matching_students(params)
    end

    # params = {username: "xxxxxxx"} or {local_id: "12345"}
    # or       {enroll_status: "x"} or {status_code: "0"}
    # or       {first_name: "John"} or {last_name: "Brown"}
    # api_path = "/ws/v1/district/student?expansions=school_enrollment,contact&q=enroll_status==A;name.last_name==J*"
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
    # {students: [
    #     {"id"=>4916, "local_id"=>112406, "student_username"=>"cccc406", "name"=>{"first_name"=>"Ssssss", "last_name"=>"CCCCC"}},
    #     {"id"=>4932, "local_id"=>112520, "student_username"=>"jjjj520", "name"=>{"first_name"=>"Ppppppp", "last_name"=>"JJJJJJJJ"}},
    #     {"id"=>4969, "local_id"=>112766, "student_username"=>"aaaa766", "name"=>{"first_name"=>"Sssss", "middle_name"=>"Aaaaaaaa", "last_name"=>"Aaaaaaaaaa"}}
    #   ]
    # }

    # params = {dcid: "xxxxxxx"} or {id: "12345"}
    def get_student(params)
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

    # params = {username: "xxxxxxx"} or {local_id: "12345"}
    def find_student(params)
      # api_path = "/ws/v1/district/student?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
      api_path   = "/ws/v1/district/student"
      options    = { query:
                    {"expansions" => "contact,contact_info,phones"}}
      query  = []
      query << "student_username==#{params[:username]}"  if params.has_key?(:username)
      query << "local_id==#{params[:local_id]}"          if params.has_key?(:local_id)

      options[:query]["q"] = query.join(";")
      pp options
      return {"errorMessage"=>{"message"=>"A valid parameter must be entered."}} if query.empty?

      answer = api(:get, api_path, options)
      { student: (answer.dig("students","student") || []) }
    end
    alias_method :find_student_by_local_id, :find_student
    alias_method :find_student_by_username, :find_student
    # {student:
    #   {"id"=>5023,
    #    "local_id"=>112193,
    #    "student_username"=>"xxxxxxx193",
    #    "name"=>{"first_name"=>"Aaaaaaaaa", "last_name"=>"EEEEEEEEE"},
    #    "school_enrollment"=>
    #      {"enroll_status"=>"A",
    #       "enroll_status_description"=>"Active",
    #       "enroll_status_code"=>0,
    #       "grade_level"=>12,
    #       "entry_date"=>"2017-08-25",
    #       "exit_date"=>"2018-06-09",
    #       "school_number"=>33,
    #       "school_id"=>6,
    #       "entry_comment"=>"Promote Same School",
    #       "full_time_equivalency"=>{"fteid"=>1070, "name"=>"FTE Value: 1"}
    #      },
    #    "contact"=>
    #       {"guardian_email"=>"parent1@example.fr,parent2@example.ch", "mother"=>"EEEEEEE, Vvvvv", "father"=>"EEEEEEEE, Sssssss"},
    #    "contact_info"=>{"email"=>"xxxxxxx193@xxxx.de"}
    #   }
    # }

    private
    # given page_size = 100
    # 430 kids = 5 pages
    # 400 kids = 4 pages
    def calc_pages(count, page_size)
      max_page  = ( (count.to_i-1) / page_size.to_i ).to_i + 1
    end
    # 5

    # api_path = "/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0"
    # returns: {"resource"=>{"count"=>423}}
    def get_matching_students_count(params={})
      api_path = "/ws/v1/district/student/count"

      query  = []
      query << "student_username==#{params[:username]}"  if params.has_key?(:username)
      query << "local_id==#{params[:local_id]}"          if params.has_key?(:local_id)
      query << "name.last_name==#{params[:last_name]}"   if params.has_key?(:last_name)
      query << "name.first_name==#{params[:first_name]}" if params.has_key?(:first_name)
      query << "school_enrollment.enroll_status==#{params[:enroll_status]}"    if params.has_key?(:enroll_status)
      query << "school_enrollment.enroll_status_code==#{params[:status_code]}" if params.has_key?(:status_code)

      options = {query: {"q" => query.join(";")} }
      pp options
      return {"errorMessage"=>{"message"=>"A valid parameter must be entered."}} if query.empty?

      answer  = api(:get, api_path, options)  # {"resource"=>{"count"=>423}}
      answer.dig("resource", "count").to_i
    end
    # 423

    # params = {username: "xxxxxxx"} or {local_id: "12345"}
    # or       {enroll_status: "x"} or {status_code: "0"}
    # or       {first_name: "John"} or {last_name: "Brown"}
    # api_path = "/ws/v1/district/student?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
    def get_matching_students_page(params)
      api_path = "/ws/v1/district/student"
      params[:page_size]   ||= 100
      params[:page_number] ||= 1
      pp params
      options = { query:
                  { "pagesize"    => "#{params[:page_size]}",
                    "page"        => "#{params[:page_number]}"} }
      query  = []
      query << "student_username==#{params[:username]}"  if params.has_key?(:username)
      query << "local_id==#{params[:local_id]}"          if params.has_key?(:local_id)
      query << "name.last_name==#{params[:last_name]}"   if params.has_key?(:last_name)
      query << "name.first_name==#{params[:first_name]}" if params.has_key?(:first_name)
      query << "school_enrollment.enroll_status==#{params[:enroll_status]}"    if params.has_key?(:enroll_status)
      query << "school_enrollment.enroll_status_code==#{params[:status_code]}" if params.has_key?(:status_code)

      options[:query]["q"] = query.join(";")
      return {"errorMessage"=>{"message"=>"A valid parameter must be entered."}} if query.empty?
      pp options
      api(:get, api_path, options)
    end
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


  end

end
