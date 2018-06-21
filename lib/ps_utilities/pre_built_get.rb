module PsUtilities

  module PreBuiltGet

    def get_active_students_count(params={})
      # api_path = "/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0"
      api_path = "/ws/v1/district/student/count"
      options  = { query: {"q" => "school_enrollment.enroll_status_code==0"} }
      get(api_path, options)
    end

    def get_active_students_info(params={})
      # api_path = "/ws/v1/district/student?q=school_enrollment.enroll_status==a&pagesize=500"
      api_path     = "/ws/v1/district/student"
      options = { query:
                  {"q"        => "school_enrollment.enroll_status_code==0",
                   "pagesize" => "500"} }
      get(api_path, options)
    end

    # params = {username: "xxxxxxx"}
    def get_one_student_record(params)
      # api_path = "/ws/v1/district/student?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
      api_path = "/ws/v1/district/student"
      options  = { query:
                  { "q"          => "student_username==#{params[:username]}",
                    "expansions" => "school_enrollment,contact,contact_info"} }
      get(api_path, options)
    end

  end

end
