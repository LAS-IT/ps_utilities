# PsUtilities

Ruby wrapper for Powerschool API interaction - without using rails dependencies.

This uses oauth2 to connection to the Powerschool API.

This code is heavily refactored code from: https://github.com/TomK32/powerschool

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ps_utilities'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ps_utilities

## ToDo

- add docs
- add example code
- account creation?
- account updates?
- web mock and more tests
- add additional prebuilt commands
- recursion when retrieving all kids?
- contact others interested in PS API for collaboration

## Change Log

* **v0.2.2** - 2018-06-??
  - update / improve code docs
* **v0.2.1** - 2018-06-21 --
  - internal refactoring - pushed accidentally before writing docs - oops
* **v0.2.0** - 2018-06-21 - not compatible with v0.1.0
  - update api - using api_path for clarity
* **v0.1.0** - 2018-06-21
  - get student counts and get all students (up to 500 kids) - no paging yet

## Usage

```ruby
require 'ps_utilities'

# INSTANTIATE
#############

# use parameters
# ps = PsUtilities::Connection.new(
#      { base_uri: 'https://ps.school.k12/',
#        auth_endpoint: '/oauth/access_token',
#        client_id: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
#        client_secret:  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#      }
# )

# Required ENV_Vars - found at:
# System>System Settings>Plugin Management Configuration>your plugin>Data_Provider_Configuration
# ENV['PS_URL'] = 'https://ps.school.k12/'              # (no default)
# ENV['PS_AUTH_ENDPOINT'] = '/oauth/access_token'       # (the default)
# ENV['PS_CLIENT_ID'] = '23qewrdfghjuy675434ertyui'     # (no default)
# ENV['PS_CLIENT_SECRET'] = '43ertfghjkloi9876trdfrdfg' # (no default)
# ENV['PS_ACCESS_TOKEN'] = nil                          # (not recommended)

# use ENV Vars and just do:
ps = PsUtilities::Connection.new
pp ps

# see connection class connection info
# run with no params - just authenticates (gets token)
ps.run(command: :authenticate)
# or
ps.run

#
api_path = "/ws/v1/district/student/count"
options  = { query: { "q" => "school_enrollment.enroll_status_code==0" } }
count    = ps.run( command: :get, api_path: api_path, options: options )
# or
# pre-build common command
count    = ps.run( command: :get_active_students_count )
pp count
# => {"resource"=>{"count"=>423}}

# list of active students
page_number = 2
api_path = "/ws/v1/district/student"
options  = { query: { "q"=>"school_enrollment.enroll_status==a",
                      "pagesize"=>"500",
                      "page"=> "#{page_number}" } }
kids     = ps.run( command: :get, api_path: api_path, options: options )
# or
# pre-built
kids     = ps.run( command: :get_active_students_info )
pp kids
# => {"students"=>
#   {"@expansions"=>
#     "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
#    "@extensions"=>
#     "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
#    "student"=>
#     [
#       {"id"=>4916, "local_id"=>112406, "student_username"=>"xxxx406", "name"=>{"first_name"=>"Xxxxxx", "last_name"=>"xxxxx"}},
#       {"id"=>5037, "local_id"=>112380, "student_username"=>"yyyyy380", "name"=>{"first_name"=>"Yyyyyy", "last_name"=>"YYYYY"}},
#     ]
#   }
# }


# get one kid - using multiple extensions
api_path = "/ws/v1/district/student"
option   =  { query: {"expansions"=>"school_enrollment,contact,contact_info",
                      "q"         =>"student_username==user237"} }
one      = ps.run(command: :get, api_path: api_path )
# or
# pre-built
params   = {username: "user237"}
one      = ps.run(command: :get_one_student_record, params: params )
# => {"students"=>
#   {"@expansions"=>
#     "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
#    "@extensions"=>
#     "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
#    "student"=>
#     {"id"=>5999,
#      "local_id"=>103237,
#      "student_username"=>"aaaaaaa237",
#      "name"=>{"first_name"=>"Aaaaaa", "last_name"=>"AAAAAAAAA"},
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
#        "full_time_equivalency"=>{"fteid"=>1070, "name"=>"FTE Value: 1"}}}}}

```

## PowerSchool API Notes

### POST to Authenticate with Oauth2
```
base64_credentials = Base64.encode64( [client_id,client_secret].join(":") ).gsub(/\n/, '')
HTTParty.post( "#{base_uri}/oauth/access_token",
              { body: 'grant_type=client_credentials',
                headers: {
                  'ContentType' => 'application/x-www-form-urlencoded;charset=UTF-8',
                  'Accept' => 'application/json',
                  'Authorization' => "Basic #{base64_credentials}"
                }
              })
```

### Headers after Authentication
```
{:headers=>
  { "User-Agent"=>"PsUtilitiesGem - v0.2.2",
    "Accept"=>"application/json",
    "Content-Type"=>"application/json",
    "Authorization"=>"Bearer #{authorized_token}"
  }
}
```

### Query Operators for GETS - https://support.powerschool.com/developer/#/page/searching
* **=gt=** - greater than
* **=ge=** - greater than or equal to
* **=lt=** - less than
* **=le=** - less than or equal to
* **==**   - equal to
```
Join query criteria with ";" 

# EXAMPLE QUERY
/ws/v1/district/student/count?q=school_enrollment.enroll_status==A;school_enrollment.entry_date=gt=2017-08-01
```

### Large Query Options - PAGINATION - https://support.powerschool.com/developer/#/page/pagination
* **page_number** - The n-th set of records. The default value is 1.
* **page_size**   - The maximum number of students returned per page. This value cannot be greater than the PowerSchool Max Request Number, which is the default value (although changes can take a while).
```
# Paging when getting all students
/ws/v1/district/student?page={page_number}&pagesize={page_size}
#
# Paging with a query
/ws/v1/district/student?page={page_number}&pagesize={page_size}&q=school_enrollment.enroll_status==A;school_enrollment.entry_date=gt=2017-08-01
```

### Data Dictionary -- Fields in the body - that can be updated:
* https://support.powerschool.com/developer/#/page/data-dictionary#student

### Example Details on Districts - GET - /ws/v1/district
* **GET /ws/v1/district** - District Info https://support.powerschool.com/developer/#/page/district-resources
* **GET /ws/v1/district/school** - School Info within District
* **GET /ws/v1/district/school/count** - Count Schools within District
* **GET /ws/v1/district/student** - Student Info within District
* **GET /ws/v1/district/student/count** - Student Info within District
* **STUDENT QUERIES:**
  - **student_username** - Valid student usernames. Internationalized characters are supported.
  - **local_id** - Valid student number.
  - **name.last_name** - String with optional wildcard *, for example Ada*. Internationalized characters are also supported.
  - **school_enrollment.enroll_status_code** - Any integer: 0 (Active), -1 (Pre-Registered), 2 (Transferred-Out), 3 (Graduated), 4 (Historical), and all others integers are considered Inactive.
  - **school_enrollment.enroll_status** - One of the following letters, case-insensitive: A (Active), P (Pre-Registered), T (Transferred-Out), G (Graduated), H (Historical), I (Inactive) -- this is translated to an enroll_status_code prior to the filter.
  - **school_enrollment.entry_date** -- Date with format YYYY-MM-DD.
  - **state_province_id**
* **EXPANSIONS:** (get extra details) - be careful with this when pulling many students
  - addresses
  - alerts
  - contact
  - contact_info
  - demographics
  - ethnicity_race
  - fees
  - initial_enrollment
  - lunch
  - phones
  - schedule_setup
  - school_enrollment


### MORE API PATHS (END POINTS) OVERVIEWS
**HELPFUL DOCS**
- https://support.powerschool.com/developer/#/page/resources
- https://support.powerschool.com/developer/#/page/data-dictionary#student_id

**Seachable API Calls**
* (/ws/schema) - https://support.powerschool.com/developer/#/page/powerquery-resources
* (all other paths) - https://support.powerschool.com/developer/#/page/core-resources

**END POINTS - API PATHS**

* **GENERAL INFO** - */ws/v1*
  * **Course Info** - https://support.powerschool.com/developer/#/page/course-resources
  - **GET /ws/v1/course/{id}** - Course info
  * --------
  * **Distrect Info** - https://support.powerschool.com/developer/#/page/district-resources
  * **GET /ws/v1/district** - District Info
  * **GET /ws/v1/district/school** - School Info within District
  * **GET /ws/v1/district/school/count** - Count Schools within District
  * **GET /ws/v1/district/student** - Student Info within District
  * **GET /ws/v1/district/student/count** - Student Info within District
  * --------
  * **Event Subscriptions** - https://support.powerschool.com/developer/#/page/event-subscription-resources
  * **GET /ws/v1/event_subscription** - Get Event Subscriptions -
  * **PUT /ws/v1/event_subscription** - Update Event Subscriptions
  * **DELETE /ws/v1/event_subscription** - Delete Event Subscriptions
  * --------
  * **Student Fee Transaction** - https://support.powerschool.com/developer/#/page/fee
  * **POST /ws/v1/fee/transaction**
  * --------
  * **School Info** - https://support.powerschool.com/developer/#/page/school-resources
  * **GET /ws/v1/school/{id}** - Return School infomation
  * **GET /ws/v1/school/{school_id}/course** - Return course(s). The courses are sorted by course number
  * **GET /ws/v1/school/{school_id}/course/count** - Retrieve the number of courses in a school.
  * **GET /ws/v1/school/{school_id}/section** - Search the school for sections matching the specified criteria. The sections are sorted by section_id, course_id and term_id.
  * **GET /ws/v1/school/{school_id}/section/count** - Count the number of sections matching the specified criteria in a school.
  * **GET /ws/v1/school/{school_id}/staff** - Search the school for staff. The results are limited to staff that have an active status. The staff is sorted by ID.
  * **GET /ws/v1/school/{school_id}/staff/count** - Count staff in a school matching the query criteria
  * **GET /ws/v1/school/{school_id}/student** - Students by school - matching the criteria
  * **GET /ws/v1/school/{school_id}/student/count** - Count students in a school matching the query criteria
  * **GET /ws/v1/school/{school_id}/term** - Search the school for terms matching the specified criteria. The terms are sorted by portion and start_date.
  * **GET /ws/v1/school/{school_id}/term/count** - count terms matching the query criteria
  * --------
  * **Section Enrollment** - https://support.powerschool.com/developer/#/page/section-enrollment-resource
  * **GET /ws/v1/section_enrollment/{id}**
  * --------
  * **Sections** - https://support.powerschool.com/developer/#/page/section-resources
  * **GET /ws/v1/section/{id}** - Get sections by id
  * **GET /ws/v1/section/{id}/section_enrollment** - Search the section for section enrollments matching the specified criteria. The section enrollments are sorted by student_id and entry_date.
  * --------
  * **Staff IDs** - https://support.powerschool.com/developer/#/page/staff-resource
  * **GET /ws/v1/staff/{id}** - Return a staff by ID
  * --------
  * **Students By ID** - https://support.powerschool.com/developer/#/page/student-resources
  * **GET /ws/v1/student/{id}** - return a student by dcid
  * **GET /ws/v1/student/{id}/gpa** - return a student's gpa using the student dcid
  * **POST /ws/v1/student** - update a student (why a post and not a put?) also see api data_dictionary for available fields to update: https://support.powerschool.com/developer/#/page/data-dictionary#student
  * **GET /ws/v1/student/{student_id}/test** - get all matching student tests
  * **POST /ws/v1/student/test** - update or insert student test details
  * --------
  * **Term Info** - https://support.powerschool.com/developer/#/page/term-resource
  * **GET /ws/v1/term/{id}** - Return term info by ID
  * --------
  * **Test Subscription**
  * **GET /ws/v1/test_subscription**
  * --------
  * **Get PowerSchool Date/Time** - https://support.powerschool.com/developer/#/page/time-resource
  * **GET /ws/v1/time** - Return the current date, time and timestamp of the PowerSchool server. This resource does not require OAuth authentication.

* **/ws/xte**

* **GLOBAL INFO** - */ws/schema/* - PowerSchool Global information (tables, etc) - https://support.powerschool.com/developer/#/page/global-resources
  * **GET /ws/schema/area** - Functional Areas
  * -----
  * **TABLES** - https://support.powerschool.com/developer/#/page/table-resources
  * **GET /ws/schema/table** - Get All Tables
  * **GET /ws/schema/table/{table_name}/{id}&projection={projection}** - projection -
A comma-delimited list indicating the desired columns to be included in the api call. An asterisk * may be supplied to return all columns, but it is recommended to specify only necessary columns whenever possible.
  * **POST /ws/schema/table/{table_name}** - Add Record to Database Extension Tables
  * **PUT /ws/schema/table/{table_name}/{id}** - Update Record from Database Extension Tables
  * **DELETE /ws/schema/table/{table_name}/{id}** - Delete Record from Database Extension Tables
  * **GET /ws/schema/table/{table_name}/count?q={query_expression}** - Get Record Count from Database Tables
  * **GET /ws/schema/table/{table_name}?q={query_expression}&page={page}&pagesize={pagesize}&projection={projection}** - Get Multiple Records from Database Tables
  * -------
  * **GET /ws/v1/metadata** - Get Global Metadata Info
  * **GET /ws/schema/table/{tablename}/metadata** - Get Table Metadata
  * **GET /ws/schema/area/{areaname}/table** - Get All Tables for Functional Areas
  * ------
  * **Guardian Info** - https://support.powerschool.com/developer/#/page/student-resources
  * **POST /ws/schema/query/com.pearson.core.guardian.student_guardian_detail** - (why a post and not a get?) Return all guardian records that satisfy the specified criteria.
  * **POST /ws/schema/query/com.pearson.core.guardian.student_guardian_detail/count** - count matching guardian records
  * -------
  * **Student DCID to Student_id map
  * **POST /ws/schema/query/com.pearson.core.student.student_dcid_id_map** -

* **PowerQuery Access List Info** - */ws/powerqueryaccesslist/* - https://support.powerschool.com/developer/#/page/global-resources
  * **GET /ws/powerqueryaccesslist/** - Get All PowerQueries Access List - List of all fields access by all trusted PowerQueries, formatted as view-only access requests. Includes all fields that are not blacklisted or are whitelisted
  * **GET /ws/powerqueryaccesslist/{QueryName}** - List of all fields access by the named PowerQuery, formatted as view-only access requests. Includes all fields that are not blacklisted or are whitelisted

* **PowerTeacher and Assignments** - */powerschool-ptg-api/v2/* - https://support.powerschool.com/developer/#/page/assignment-resources
  * **Assigments** - https://support.powerschool.com/developer/#/page/assignment-resources
  * **GET /powerschool-ptg-api/v2/assignment/{id}** - get all details for an assignment
  * **PUT /powerschool-ptg-api/v2/assignment/{id}** -
  * **POST /powerschool-ptg-api/v2/section/{id}/assignment** - add assignments
  * -------
  * **GET /powerschool-ptg-api/v2/translate/{entity}/{source_product}/{source_col}/{target_product}/{target_col}?values=** - https://support.powerschool.com/developer/#/page/translate-resource - Translate one or more identifiers for one entity into the identifiers of another entity.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ps_utilities.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
