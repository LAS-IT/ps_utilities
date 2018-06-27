# list 100 active students - starting with the second 100 kids
page_number = 2
api_path = "/ws/v1/district/student"
options  = { query: { "q"=>"school_enrollment.enroll_status==a",
                      "pagesize"=>"100",
                      "page"=> "#{page_number}" } }
kids     = ps.run( command: :get, api_path: api_path, options: options )



# get all active students with last_name starting with B
api_path = "/ws/v1/district/student"
options  = { query: { "q" => "name.last_name==B*;school_enrollment.enroll_status_code==0" } }
kids    = ps.run( command: :get, api_path: api_path, options: options )

api_path = "/ws/v1/district/student"
option   =  { query: {
                      "extensions" => "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
                      "expansions" => "demographics,addresses,alerts,phones,school_enrollment,ethnicity_race,contact,contact_info,initial_enrollment,schedule_setup,fees,lunch",
                      "q"          => "student_username==user*;name.last_name==B*"
                    }
            }
kids    = ps.run( command: :get, api_path: api_path, options: options )




# get all details and database extension data on one kid (need to use the DCID)
api_path = "/ws/v1/student/5122"
option   =  { query: {
                      "extensions" => "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
                      "expansions" => "demographics,addresses,alerts,phones,school_enrollment,ethnicity_race,contact,contact_info,initial_enrollment,schedule_setup,fees,lunch"
                      }
            }
one      = ps.run(command: :get, api_path: api_path )
