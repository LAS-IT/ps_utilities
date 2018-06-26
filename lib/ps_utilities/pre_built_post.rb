module PsUtilities

  module PreBuiltPost

    # params[:students] (Array of Hashes) - kids with their attributes
    # params = {dcid: 7531, student_id: 23456}
    # or
    # params = { [ {dcid: 7531, student_id: 23456},
    #               {dcid: 9753, student_id: 65432} ] }
    def create_students(params)
      action   = "INSERT"
      kids_api_array = build_kids_api_array(action, params)
      options  = { body: { students: { student: kids_api_array } }.to_json }
      answer = api(:post, "/ws/v1/student", options)
    end
    alias_method :create_student, :create_students
    # { "results": {
    #     "update_count": 2
    #     "result": [
    #       {  "client_uid": 124,
    #          "status": "SUCCESS",
    #          "action": "INSERT",
    #          "success_message" :{
    #            "id": 442,
    #            "ref": "https://server/ws/v1/student/442" }
    #        },
    #        { ... }
    #     ]
    #   }
    # }

    # params[:students] (Array of Hashes) - kids with their attributes
    def update_students(params)
      action = "UPDATE"
      kids_api_array = build_kids_api_array(action, params)
      options  = { body: { students: { student: kids_api_array } }.to_json }
      answer = api(:post, "/ws/v1/student", options)
    end
    alias_method :update_student, :update_students
    # { "results": {
    #     "update_count": 2
    #     "result": [
    #       {  "client_uid": 124,
    #          "status": "SUCCESS",
    #          "action": "INSERT",
    #          "success_message" :{
    #            "id": 442,
    #            "ref": "https://server/ws/v1/student/442" }
    #        },
    #        { ... }
    #     ]
    #   }
    # }

    def build_kids_api_array(action, params)
      unless params[:students].is_a? Array
        return {"errorMessage"=>{"message"=>"Student Data (in Hash format) must be in an Array."}}
      end
      kids_api_array  = []
      params[:students].each do |kid|
        kid[:las_extensions] = true if params[:las_extensions]
        kids_api_array << build_kid_attributes(action, kid)
      end
      return kids_api_array
    end

    def build_kid_attributes(action, kid)
      # ALWAYS NEEDED INFO
      attribs                        = {action: action}
      attribs[:id]                   = kid[:id] || kid[:dcid]
      attribs[:client_uid]           = kid[:student_id].to_s
      attribs[:student_username]     = kid[:username]

      # REQUIRED ON ENROLLMENT (optional later)
      attribs[:name]                 = {}
      case action
      when 'INSERT'
        # must be set on creation
        attribs[:local_id]  = kid[:oa_id].to_i
        # to create an account both first and last name must be present
        attribs[:name][:last_name]   = kid[:last_name]   if kid[:last_name] or kid[:first_name]
        attribs[:name][:first_name]  = kid[:first_name]  if kid[:last_name] or kid[:first_name]
        attribs[:name][:middle_name] = kid[:middle_name] if kid[:middle_name]
        # school_enrollment can only be SET on INSERT!
        attribs[:school_enrollment]  = {}
        if kid[:enroll_status_code]
          attribs[:school_enrollment][:enroll_status_code] = kid[:enroll_status_code]
        elsif kid[:status_code]
          attribs[:school_enrollment][:status_code]  = kid[:status_code]
        end
        attribs[:school_enrollment][:grade_level]    = kid[:grade_level]   if kid[:grade_level]
        attribs[:school_enrollment][:entry_date]     = kid[:entry_date]    if kid[:entry_date]
        attribs[:school_enrollment][:exit_date]      = kid[:exit_date]     if kid[:exit_date]
        attribs[:school_enrollment][:school_number]  = kid[:school_number] if kid[:school_number]
        attribs[:school_enrollment][:school_id]      = kid[:school_id]     if kid[:school_id]
      when 'UPDATE'
        # don't allow nil / blank name updates
        attribs[:name][:last_name]   = kid[:last_name]   if kid[:last_name]
        attribs[:name][:first_name]  = kid[:first_name]  if kid[:first_name]
        attribs[:name][:middle_name] = kid[:middle_name] if kid[:middle_name]
      end

      # OPTIONAL
      attribs[:contact] = {}
      if kid[:emergency_phone1] && kid[:emergency_contact_name1]
        attribs[:contact][:emergency_phone1]        = kid[:emergency_phone1]
        attribs[:contact][:emergency_contact_name1] = kid[:emergency_contact_name1]
      end
      if kid[:emergency_phone2] && kid[:emergency_contact_name2]
        attribs[:contact][:emergency_phone2]        = kid[:emergency_phone2]
        attribs[:contact][:emergency_contact_name2] = kid[:emergency_contact_name2]
      end
      if kid[:doctor_phone] && kid[:doctor_name]
        attribs[:contact][:doctor_phone]  = kid[:doctor_phone]
        attribs[:contact][:doctor_name]   = kid[:doctor_name]
      end
      attribs[:contact][:guardian_email]  = kid[:guardian_email]   if kid[:guardian_email]
      attribs[:contact][:guardian_fax]    = kid[:guardian_fax]     if kid[:guardian_fax]
      attribs[:contact][:mother]          = kid[:mother]           if kid[:mother]
      attribs[:contact][:father]          = kid[:father]           if kid[:father]
      attribs[:contact] = nil            if attribs[:contact].empty?
      #
      attribs[:demographics] = {}
      attribs[:demographics][:gender]     = kid[:gender]           if kid[:gender]
      attribs[:demographics][:birth_date] = kid[:birth_date]       if kid[:birth_date]
      attribs[:demographics][:projected_graduation_year] = kid[:projected_graduation_year] if kid[:projected_graduation_year]
      attribs[:demographics][:ssn]        = kid[:ssn]              if kid[:ssn]
      #
      attribs[:schedule_setup] = {}
      attribs[:schedule_setup][:home_room]   = kid[:home_room]     if kid[:home_room]
      attribs[:schedule_setup][:next_school] = kid[:next_school]   if kid[:next_school]
      attribs[:schedule_setup][:sched_next_year_grade] = kid[:sched_next_year_grade] if kid[:sched_next_year_grade]
      #
      attribs[:school_enrollment] = {}
      if kid[:enroll_status_code]
        attribs[:school_enrollment][:enroll_status_code]  = kid[:enroll_status_code]
      elsif kid[:status_code]
        attribs[:school_enrollment][:status_code]         = kid[:status_code]
      end
      attribs[:school_enrollment][:grade_level]    = kid[:grade_level]   if kid[:grade_level]
      attribs[:school_enrollment][:entry_date]     = kid[:entry_date]    if kid[:entry_date]
      attribs[:school_enrollment][:exit_date]      = kid[:exit_date]     if kid[:exit_date]
      attribs[:school_enrollment][:school_number]  = kid[:school_number] if kid[:school_number]
      #
      attribs[:contact_info]     = {email: kid[:email]}           if kid[:email]
      attribs[:phone]            = {main: {number: kid[:mobile]}} if kid[:mobile]

      # Update LAS Database Extensions as needed
      attribs["_extension_data"] = calc_las_extensions(kid)      if kid[:las_extensions].to_s.eql?("true")

      # return attributes - first remove, nils, empty strings and empty hashes
      answer = attribs.reject { |k,v| v.nil? || v.to_s.empty? || v.to_s.eql?("{}")}
      pp answer
      return answer
    end
    # Data structure to send to API
    # options = {body: {
    #      "students":{
    #         "student":[
    #            {
    #               "client_uid":"124",
    #               "action":"UPDATE",
    #               "id":"442",
    #               "name":{
    #                  "first_name":"Aaronia",
    #                  "last_name":"Stephaniia"
    #               },
    #            },
    #            { ... }
    #         ]
    #      }
    #   }
    # }

    def calc_las_extensions(kid)
      # attribs = {}
      # attribs["_table_extension"] = []
      attribs = { "_table_extension" => [] }
      if kid[:email] or kid[:preferred_name]
        db_extensions =
          { "recordFound"=>false,
            "name"=>"u_students_extension",
            "_field"=> [ ]
          }
        if kid[:email]
          db_extensions["_field"] << {"name"=>"student_email", "type"=>"String", "value"=>"#{kid[:email]}"}
        end
        if kid[:preferredname]
          db_extensions["_field"] << {"name"=>"preferredname", "type"=>"String", "value"=>"#{kid[:preferredname]}"}
        end
        if kid[:preferred_name]
          db_extensions["_field"] << {"name"=>"preferredname", "type"=>"String", "value"=>"#{kid[:preferred_name]}"}
        end
        attribs["_table_extension"] << db_extensions
        # { "recordFound"=>false,
        #   "name"=>"u_students_extension",
        #   "_field"=> [
        #     {"name"=>"preferredname", "type"=>"String", "value"=>"Niko"},
        #     {"name"=>"student_email", "type"=>"String", "value"=>"#{kid[:email]}"}
        #   ]
        # }
      end
      if kid[:transcriptaddrline1] or kid[:transcriptaddrline2] or
          kid[:transcriptaddrcity] or kid[:transcriptaddrstate] or
          kid[:transcriptaddrzip]  or kid[:transcriptaddrcountry]
        db_extensions =
          { "recordFound"=>false,
            "name"=>"u_studentsuserfields",
            "_field"=> [ ]
          }
        if kid[:transcriptaddrline1]
          db_extensions["_field"] << {"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"#{kid[:transcriptaddrline1]}"}
        end
        if kid[:transcriptaddrline2]
          db_extensions["_field"] << {"name"=>"transcriptaddrline2", "type"=>"String", "value"=>"#{kid[:transcriptaddrline2]}"}
        end
        if kid[:transcriptaddrcity]
          db_extensions["_field"] << {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"#{kid[:transcriptaddrcity]}"}
        end
        if kid[:transcriptaddrzip]
          db_extensions["_field"] << {"name"=>"transcriptaddrzip", "type"=>"String", "value"=>"#{kid[:transcriptaddrzip]}"}
        end
        if kid[:transcriptaddrstate]
          db_extensions["_field"] << {"name"=>"transcriptaddrstate", "type"=>"String", "value"=>"#{kid[:transcriptaddrstate]}"}
        end
        if kid[:transcriptaddrcountry]
          db_extensions["_field"] << {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"#{kid[:transcriptaddrcountry]}"}
        end
        attribs["_table_extension"] << db_extensions
        # { "recordFound"=>false,
        #   "name"=>"u_studentsuserfields",
        #   "_field"=> [
        #     {"name"=>"transcriptaddrzip", "type"=>"String", "value"=>75230},
        #     {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"United States"},
        #     {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"dallas"},
        #     {"name"=>"transcriptaddrstate", "type"=>"String", "value"=>"Texas"},
        #     {"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"6138 meadow rd"}
        #   ]
        # }
      end
      pp attribs
      attribs
    end
    # to inject into _extension_data
    # { "_table_extension"=> [
    #     { "recordFound"=>false,
    #       "name"=>"u_students_extension",
    #       "_field"=> [
    #         {"name"=>"preferredname", "type"=>"String", "value"=>"Jimmy"},
    #         {"name"=>"student_email", "type"=>"String", "value"=>"bbaaccdd@las.ch"}
    #       ]
    #     },
    #     { "recordFound"=>false,
    #       "name"=>"u_studentsuserfields",
    #       "_field"=> [
    #         {"name"=>"transcriptaddrzip", "type"=>"String", "value"=>8154},
    #         {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"Switzerland"},
    #         {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"Leysin"},
    #         {"name"=>"transcriptaddrstate", "type"=>"String", "value"=>"Vaud"},
    #         {"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"6789 linden st"}
    #       ]
    #     }
    #   ]
    # }

  end

end
