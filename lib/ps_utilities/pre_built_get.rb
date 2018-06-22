module PsUtilities

  module PreBuiltGet

    # params = {username: "xxxxxxx"} or {local_id: "12345"}
    def get_one_student_record(params)
      # api_path = "/ws/v1/district/student?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
        api_path               = "/ws/v1/district/student"
        options = { query:
                    {"expansions" => "school_enrollment,contact,contact_info"}
                  }
      if params.has_key?(:username)
        options[:query]["q"]   =  "student_username==#{params[:username]}"
      elsif params.has_key?(:local_id)
        options[:query]["q"]   =  "local_id==#{params[:local_id]}"
      else
        return {"errorMessage"=>{"message"=>"Parameter must be given."}}
        # return {"errorMessage"=>{"message"=>"Parameter must be assigned a value, incomplete request received."}}
      end
      api(:get, api_path, options)
    end
    # {"students"=>
    #   {"@expansions"=>
    #     "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #    "@extensions"=>
    #     "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #    "student"=>
    #     {"id"=>5023,
    #      "local_id"=>112193,
    #      "student_username"=>"xxxxxxx193",
    #      "name"=>{"first_name"=>"Aaaaaaaaa", "last_name"=>"EEEEEEEEE"},
    #      "school_enrollment"=>
    #       {"enroll_status"=>"A",
    #        "enroll_status_description"=>"Active",
    #        "enroll_status_code"=>0,
    #        "grade_level"=>12,
    #        "entry_date"=>"2017-08-25",
    #        "exit_date"=>"2018-06-09",
    #        "school_number"=>33,
    #        "school_id"=>6,
    #        "entry_comment"=>"Promote Same School",
    #        "full_time_equivalency"=>{"fteid"=>1070, "name"=>"FTE Value: 1"}},
    #      "contact"=>
    #       {"guardian_email"=>"parent1@example.fr,parent2@example.ch", "mother"=>"EEEEEEE, Vvvvv", "father"=>"EEEEEEEE, Sssssss"},
    #      "contact_info"=>{"email"=>"xxxxxxx193@xxxx.de"}}
    #   }
    # }

    def get_all_active_students(params={})
      params[:page_size] ||= 500
      pages       = calc_pages(params={})
      answer      = {}
      students    = []
      (1..pages).each do |page|
        params[:page_number] = page
        answer    = get_active_students_info(params)
        students << (answer.dig("students","student") || [])
      end
      answer["students"]["student"] = students.flatten
      return answer
    end
    # {"students"=>
    #   {"@expansions"=>
    #     "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #    "@extensions"=>
    #     "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #    "student"=>
    #     [{"id"=>4916, "local_id"=>112406, "student_username"=>"chens406", "name"=>{"first_name"=>"Siting", "last_name"=>"CHEN"}},
    #      {"id"=>4932,
    #       "local_id"=>112520,
    #       "student_username"=>"jozwiap520",
    #       "name"=>{"first_name"=>"Patryk", "last_name"=>"JOZWIAK"}},
    #      {"id"=>4969,
    #       "local_id"=>112766,
    #       "student_username"=>"alhamrs766",
    #       "name"=>{"first_name"=>"Saif", "middle_name"=>"Abdulaziz", "last_name"=>"ALHAMRANI"}}
    #     ]
    #   }
    # }

    # given page_size = 100
    # 430 kids = 5 pages
    # 400 kids = 4 pages
    def calc_pages(params={})
      params[:page_size] ||= 500
      count     = get_active_students_count.dig("resource", "count").to_i
      max_page  = ( (count-1) / params[:page_size] ).to_i + 1
    end
    # 5

    # api_path = "/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0"
    # returns: {"resource"=>{"count"=>423}}
    def get_active_students_count(params={})
      api_path = "/ws/v1/district/student/count"
      options  = { query: {"q" => "school_enrollment.enroll_status_code==0"} }
      api(:get, api_path, options)
    end
    # {"resource"=>{"count"=>423}}

    # params: [HASH] - default values - params: { page_size: 500, page_number: 1 }
    # api_path = "/ws/v1/district/student?q=school_enrollment.enroll_status==a&pagesize=500&page=1"
    def get_active_students_info(params={})
      api_path               = "/ws/v1/district/student"
      params[:page_size]   ||= 500
      params[:page_number] ||= 1
      options = { query:
                  {"q"        => "school_enrollment.enroll_status_code==0",
                   "pagesize" => "#{params[:page_size]}",
                   "page"     => "#{params[:page_number]}"} }
      api(:get, api_path, options)
    end
    # {"students"=>
    #   {"@expansions"=>
    #     "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #    "@extensions"=>
    #     "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #    "student"=>
    #     [{"id"=>4916, "local_id"=>112406, "student_username"=>"chens406", "name"=>{"first_name"=>"Siting", "last_name"=>"CHEN"}},
    #      {"id"=>4932,
    #       "local_id"=>112520,
    #       "student_username"=>"jozwiap520",
    #       "name"=>{"first_name"=>"Patryk", "last_name"=>"JOZWIAK"}},
    #      {"id"=>4969,
    #       "local_id"=>112766,
    #       "student_username"=>"alhamrs766",
    #       "name"=>{"first_name"=>"Saif", "middle_name"=>"Abdulaziz", "last_name"=>"ALHAMRANI"}}
    #     ]
    #   }
    # }

    def get_all_student_matching(params)
      params[:page_size] ||= 250
      pages       = get_student_matching_count(params)
      answer      = {}
      students    = []
      (1..pages).each do |page|
        params[:page_number] = page
        answer    = get_student_matching(params)
        students << (answer.dig("students","student") || [])
      end
      answer["students"]["student"] = students.flatten
      return answer
    end
    # {"students"=>
    #   {"@expansions"=>
    #     "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #    "@extensions"=>
    #     "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #    "student"=>
    #     [{"id"=>4916, "local_id"=>112406, "student_username"=>"chens406", "name"=>{"first_name"=>"Siting", "last_name"=>"CHEN"}},
    #      {"id"=>4932,
    #       "local_id"=>112520,
    #       "student_username"=>"jozwiap520",
    #       "name"=>{"first_name"=>"Patryk", "last_name"=>"JOZWIAK"}},
    #      {"id"=>4969,
    #       "local_id"=>112766,
    #       "student_username"=>"alhamrs766",
    #       "name"=>{"first_name"=>"Saif", "middle_name"=>"Abdulaziz", "last_name"=>"ALHAMRANI"}}
    #     ]
    #   }
    # }

    # api_path = "/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0"
    # returns: {"resource"=>{"count"=>423}}
    def get_student_matching_count(params={})
      api_path = "/ws/v1/district/student/count"
      params[:page_size]   ||= 250
      params[:page_number] ||= 1
      # if params.has_key?(:username)
      #   options[:query]["q"]   = "student_username==#{params[:username]}"
      # elsif params.has_key?(:local_id)
      #   options[:query]["q"]   = "local_id==#{params[:local_id]}"
      # elsif params.has_key?(:last_name)
      #   options[:query]["q"]   = "name.last_name==#{params[:last_name]}"
      # elsif params.has_key?(:first_name)
      #   options[:query]["q"]   = "name.first_name==#{params[:first_name]}"
      # elsif params.has_key?(:enroll_status)
      #   options[:query]["q"]   = "school_enrollment.enroll_status==#{params[:enroll_status]}"
      # elsif params.has_key?(:status_code)
      #   options[:query]["q"]   = "school_enrollment.enroll_status_code==#{params[:status_code]}"
      # else
      #   return {"errorMessage"=>{"message"=>"Parameter(s) must be given."}}
      #   # return {"errorMessage"=>{"message"=>"Parameter must be assigned a value, incomplete request received."}}
      # end

      query  = []
      query << "student_username==#{params[:username]}"  if params.has_key?(:username)
      query << "local_id==#{params[:local_id]}"          if params.has_key?(:local_id)
      query << "name.last_name==#{params[:last_name]}"   if params.has_key?(:last_name)
      query << "name.first_name==#{params[:first_name]}" if params.has_key?(:first_name)
      query << "school_enrollment.enroll_status==#{params[:enroll_status]}"    if params.has_key?(:enroll_status)
      query << "school_enrollment.enroll_status_code==#{params[:status_code]}" if params.has_key?(:status_code)

      options = {query: {"q" => query.join(";")} }
      return {"errorMessage"=>{"message"=>"Parameter(s) must be given."}} if query.empty?
      api(:get, api_path, options)
    end
    # {"resource"=>{"count"=>423}}

    # params = {username: "xxxxxxx"} or {local_id: "12345"}
    # or       {enroll_status: "x"} or {status_code: "0"}
    # or       {first_name: "John"} or {last_name: "Brown"}
    # api_path = "/ws/v1/district/student?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
    def get_student_matching(params)
      api_path = "/ws/v1/district/student"
      params[:page_size]   ||= 250
      params[:page_number] ||= 1
      options = {query:
                  {"expansions" => "school_enrollment,contact,contact_info",
                  "pagesize"    => "#{params[:page_size]}",
                  "page"        => "#{params[:page_number]}"} }
      # if params.has_key?(:username)
      #   options[:query]["q"]   = "student_username==#{params[:username]}"
      # elsif params.has_key?(:local_id)
      #   options[:query]["q"]   = "local_id==#{params[:local_id]}"
      # elsif params.has_key?(:last_name)
      #   options[:query]["q"]   = "name.last_name==#{params[:last_name]}"
      # elsif params.has_key?(:first_name)
      #   options[:query]["q"]   = "name.first_name==#{params[:first_name]}"
      # elsif params.has_key?(:enroll_status)
      #   options[:query]["q"]   = "school_enrollment.enroll_status==#{params[:enroll_status]}"
      # elsif params.has_key?(:status_code)
      #   options[:query]["q"]   = "school_enrollment.enroll_status_code==#{params[:status_code]}"
      # else
      #   return {"errorMessage"=>{"message"=>"Parameter must be given."}}
      #   # return {"errorMessage"=>{"message"=>"Parameter must be assigned a value, incomplete request received."}}
      # end

      query  = []
      query << "student_username==#{params[:username]}"  if params.has_key?(:username)
      query << "local_id==#{params[:local_id]}"          if params.has_key?(:local_id)
      query << "name.last_name==#{params[:last_name]}"   if params.has_key?(:last_name)
      query << "name.first_name==#{params[:first_name]}" if params.has_key?(:first_name)
      query << "school_enrollment.enroll_status==#{params[:enroll_status]}"    if params.has_key?(:enroll_status)
      query << "school_enrollment.enroll_status_code==#{params[:status_code]}" if params.has_key?(:status_code)

      options = {query: {"q" => query.join(";")} }
      return {"errorMessage"=>{"message"=>"Parameter(s) must be given."}} if query.empty?
      api(:get, api_path, options)
    end
    # {"students"=>
    #   {"@expansions"=>
    #     "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #    "@extensions"=>
    #     "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #    "student"=>
    #     [{"id"=>4916, "local_id"=>112406, "student_username"=>"chens406", "name"=>{"first_name"=>"Siting", "last_name"=>"CHEN"}},
    #      {"id"=>4932,
    #       "local_id"=>112520,
    #       "student_username"=>"jozwiap520",
    #       "name"=>{"first_name"=>"Patryk", "last_name"=>"JOZWIAK"}},
    #      {"id"=>4969,
    #       "local_id"=>112766,
    #       "student_username"=>"alhamrs766",
    #       "name"=>{"first_name"=>"Saif", "middle_name"=>"Abdulaziz", "last_name"=>"ALHAMRANI"}}
    #     ]
    #   }
    # }

  end

end
