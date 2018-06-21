module PsUtilities

  module PreBuiltGet

    def get_active_students_count(params={})
      # url = "/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0"
      url     = "/ws/v1/district/student/count"
      options = { query: {"q" => "school_enrollment.enroll_status_code==0"} }
      get(url, options)
    end

    def get_active_students_info(params={})
      # url = "/ws/v1/district/student?q=school_enrollment.enroll_status==a&pagesize=500"
      url     = "/ws/v1/district/student"
      options = { query:
                  {"q"        => "school_enrollment.enroll_status_code==0",
                   "pagesize" => "500"}
                }
      get(url, options)
    end

    # las-test.powerschool.com/ws/v1/district/student?expansions=school_enrollment&q=student_username==xxxxx237
    # params = {username: "xxxxxxx"}
    def get_one_student_record(params)
      # url = "/ws/v1/district/student?expansions=school_enrollment,contact&q=student_username==xxxxxx237"
      url     = "/ws/v1/district/student"
      options = { query:
                  {"q"          => "student_username==#{params[:username]}",
                   "expansions" => "school_enrollment,contact,contact_info"}
                }
      get(url, options)
    end

  end

end
