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
  { "User-Agent"=>"PsUtilities - v0.3.1",
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
/ws/v1/district/student/count?q=school_enrollment.enroll_status==A;name.last_name==JA*
```

### Large Query Options - PAGINATION - https://support.powerschool.com/developer/#/page/pagination
* **page_number** - The n-th set of records. The default value is 1.
* **page_size**   - The maximum number of students returned per page. This value cannot be greater than the PowerSchool Max Request Number, which is the default value (although changes can take a while).
```
# Paging when getting all students
/ws/v1/district/student?page={page_number}&pagesize={page_size}
#
# Paging with a query
/ws/v1/district/student?page=2&pagesize=500&q=school_enrollment.enroll_status==A;school_enrollment.entry_date=gt=2017-08-01
```

### Data Dictionary -- Fields in the body - that can be updated:
* https://support.powerschool.com/developer/#/page/data-dictionary#student

### ALL STUDENTS - Use District - GET - /ws/v1/district
* **GET /ws/v1/district** - District Info https://support.powerschool.com/developer/#/page/district-resources
* **GET /ws/v1/district/school** - School Info within District
* **GET /ws/v1/district/school/count** - Count Schools within District
* **GET /ws/v1/district/student** - Student Info within District
* **GET /ws/v1/district/student/count** - Student Info within District
* **STUDENT QUERIES:** - https://support.powerschool.com/developer/#/page/searching
  - **student_username** - Valid student usernames. Internationalized characters are supported.
  - **local_id** - Valid student number.
  - **name.last_name** - String with optional wildcard *, for example Ada*. Internationalized characters are also supported.
  - **school_enrollment.enroll_status_code** - Any integer: 0 (Active), -1 (Pre-Registered), 2 (Transferred-Out), 3 (Graduated), 4 (Historical), and all others integers are considered Inactive.
  - **school_enrollment.enroll_status** - One of the following letters, case-insensitive: A (Active), P (Pre-Registered), T (Transferred-Out), G (Graduated), H (Historical), I (Inactive) -- this is translated to an enroll_status_code prior to the filter.
  - **school_enrollment.entry_date** -- Date with format YYYY-MM-DD.
  - **state_province_id**
  ```
  # queries are separated by ";"
  /ws/v1/district/student?q=school_enrollment.enroll_status==A;school_enrollment.entry_date=gt=2017-08-01
  ```
* **EXPANSIONS:** - https://support.powerschool.com/developer/#/page/expansions
(get extra details) - be careful with this when pulling many students - it can be **SLOW**
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
```
# separate multiple requests with a comma!
https://example.com/ws/v1/district/student?expansions=phones,addresses
```

### INDIVIDUAL Student - /ws/v1/student
* **Students By ID** - https://support.powerschool.com/developer/#/page/student-resources
* **POST /ws/v1/student** - update a student (why a post and not a put?) also see api data_dictionary for available fields to update: https://support.powerschool.com/developer/#/page/data-dictionary#student
* **GET /ws/v1/student/{id}** - return a student by dcid
* **GET /ws/v1/student/{id}/gpa** - return a student's gpa using the student dcid
* **GET /ws/v1/student/{student_id}/test** - get all matching student tests
* **POST /ws/v1/student/test** - update or insert student test details

**QUERIES** - are supported as shown above in the district area
**EXPANSIONS:** - are supported as shown above in the district area
**EXTENSIONS:** - https://support.powerschool.com/developer/#/page/extensions
Resource extensions are resources that extend core resources. They can be defined by the system, the installed state package, or by user-created extensions. They are based on PowerSchool schema extensions. They behave like, and are requested like, extensions. Each resource with extensions will publish them in the default result using the @extensions attribute. Zero to many elements can be selected. Unknown extension requests are ignored. If the resource is writable, such as Student, then the user-defined extensions to that resource are also writable.
```
# separate multiple requests with a comma!
curl -X GET -H "Content-Type: application/json" \
-H "Authorization: Bearer 88888888-7777-4444-bbbb-999999993333" \
https://powerschool.com/ws/v1/student/2?extensions=studentcorefields,c_studentlocator
# return:
#{"student"=>
#  {"@expansions"=>
    "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
#   "@extensions"=>
#    "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
#   "_extension_data"=>
#    {"_table_extension"=>
#      {"recordFound"=>false,
#       "_field"=>
#        [{"name"=>"transcriptaddrzip", "type"=>"String", "value"=>"050010"},
#         {"name"=>"grad_day_date_year", "type"=>"String", "value"=>"June 2018"},
#         {"name"=>"transcriptaddrcountry", "type"=>"String", "value"=>"Swizterland"},
#         {"name"=>"transcriptaddrcity", "type"=>"String", "value"=>"Almaty"},
#         {"name"=>"father_name", "type"=>"String", "value"=>"Zzzzzzzzz, Yyyyyyyy"},
#         {"name"=>"transcriptaddrline1", "type"=>"String", "value"=>"Dddddd  Str 11 app 22"},
#         {"name"=>"transcriptaddrline2", "type"=>"String", "value"=>"LAS"}],
#       "name"=>"u_studentsuserfields"}},
#   "id"=>5011,
#   "local_id"=>112036,
#   "student_username"=>"zzzzzzz036",
#   "name"=>{"first_name"=>"Tttttttt", "last_name"=>"Zzzzzzzzzz"}}}
```

**SAMPLE POST** (student record Updates)
**Student Entries -- MUST be wrapped with a *student* entity tag!**
*CLARIFY what client_uid is!!*
**NOTE how objects - like name are entered**
```
# how to post json
curl -X POST -H "Content-Type: application/json" \
-H "Authorization: Bearer 88888888-7777-4444-bbbb-999999993333" \
-d @../data/kids_file.json https://school.powerschool.com/ws/v1/student

you can post a little blob of geojson, like so:
curl -X POST -H "Content-Type: application/json" \
-H "Authorization: Bearer 88888888-7777-4444-bbbb-999999993333" \
-d '{"students":{"student":[{"client_uid":"124","action":"UPDATE","id":"442","name":{"first_name":"Aaronia","last_name":"Stephaniia"}},{"client_uid":"1245","action":"UPDATE","id":"443","name":{"first_name":"Chauncey","last_name":"McTavish"}}]}}' https://school.powerschool.com/ws/v1/student/
# nicely formatted it looks like:
body: {
   students: {
      student:[
         {  client_uid: "124",
            action: "UPDATE",
            id: "442",
            name: {
               first_name: "Aaronia",
               last_name: "Stephaniia"
            },
         },
         {  :client_uid: "1245",
            action: "UPDATE",
            id: "443",
            name: {
               first_name: "Chauncey",
               last_name: "McTavish"
            }
         }
      ]
   }
}.to_json

```

**STUDENT DATA - FIELDS** - This is a summary of the most important fields to create & update students.

The full list of fields is at: https://support.powerschool.com/developer/#/page/data-dictionary#student

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| student/client_uid    |         | string   |        |                 | Unique string that is required on ENROLL or UPDATE - only with POST Not present in a GET response - **? what is this required field ?** |
| student/action        |         |          |        |                        | UPDATE or INSERT - only on POST |
| student/id            |         | long int |        | Students.DCID          | Sequential Number - quaranteed unique |
| student/local_id      | INSERT  | long int |        | Students.Student_Number| number assigned by the school |
| student/state_province_id | INSERT, UPDATE | String | 32 |Students.State_StudentNumber|The state-assigned student number. In most cases, this number should remain the same from school to school. |
| student/student_username  |     | string   | 20     | Students.Student_Web_ID| The student user ID for signing in to PowerSchool. |

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/name**      |         | Object   |        |                 |             |
| student/name/last_name|INSERT, UPDATE|String| 50 | Students.Last_Name | **Required when enrolling a new student.** May not be updated to blank.The student's last name.|
|student/name/first_name|INSERT, UPDATE|String| 50 | Students.First_Name| **Required when enrolling a new student.** May not be updated to blank. The student's first name.|
|student/name/middle_name|INSERT, UPDATE|String|30 | Students.Middle_Name | The student's middle name.|


|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/school_enrollment** | | Object   |        |                 |             |
| student/school_enrollment/enroll_status_code|INSERT|Integer|2|Students.Enroll_Status|This field can be any integer. However, on an insert, it cannot be values 2 or 3, which correspond to Graduated and Transferred-Out. On an insert, either this field or enroll_status can be used to specify enrollment status, but both fields may not be specified at the same time. The student's enrollment status. Valid values: 0=Active, -1=Pre-Registered, 2=Transferred-Out, 3=Graduated, 4=Historical, Any other integer=Inactive|
| student/school_enrollment/enroll_status|INSERT|String|2| Students.Enroll_Status | This field is restricted to A, I, P, and H on an insert (or their lower-case equivalents). On an insert, either this field or enroll_status_code can be used to specify enrollment status, but both fields may not be specified at the same time. The student's enrollment status. Valid values: A=Active, P=Pre-Registered, T=Transferred-Out, G=Graduated, H=Historical, I=Inactive|
| student/school_enrollment/enroll_status_description|READ|String|2|Students.Enroll_Status| The student's enrollment status description. This field is a textual representation of the enroll_status. Status 0 has description Active, -1=Pre-Registered, 2=Transferred-Out, 3=Graduated, 4=Historical, Any other integer=Inactive|
| student/school_enrollment/grade_level|INSERT|String||Students.Grade_Level| **Required when enrolling a new student.** The grade the student is in. Valid values: {-1,-2,etc.}=Preschool, 0=Kindergarten, {1,2,etc.}={1,2,etc.}.|
|student/school_enrollment/entry_date|INSERT|Date||Students.EntryDate| **Required when enrolling a new student.** The date the student enrolled in school for the current enrollment. **FORMAT: YYYY-MM-DD**|
|student/school_enrollment/exit_date|INSERT|Date||Students.ExitDate| **Required when enrolling a new student.** The date the student exited for the current/last enrollment. This is the day after the student last attended class. **FORMAT: YYYY-MM-DD**|
|student/school_enrollment/school_number|INSERT|Integer||Students.SchoolID|**Required when enrolling a new student.** The ID is linked to the School_Number from the school.|
|student/school_enrollment/school_id| |Long||Schools.DCID|The ID of the student|
|student/school_enrollment/entry_code|INSERT|String|10|Students.EntryCode|Must be a valid entry code defined by the district.	The entry code for the school the student is or was enrolled in.|
|student/school_enrollment/entry_comment|INSERT|String|4000|Students.TransferComment|The entry comment for the school the student is or was enrolled in.|
|student/school_enrollment/exit_code|INSERT|String|10|Students.ExitCode|Must be a valid exit code defined by the district. The exit code for the school the student was enrolled in.|
|student/school_enrollment/exit_comment|INSERT|String|4000|Students.ExitComment|The comments pertaining to the student no longer being enrolled at the school.|
|student/school_enrollment/district_of_residence|INSERT|String|20|Students.DistrictOfResidence|Must be a valid district of residence defined by the district. The student's district of residence.|
|student/school_enrollment/track|INSERT|String|20|Students.Track|Valid tracks include: {A,B,C,D,E,F}. The student's track.|
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
|**student/school_enrollment/full_time_equivalency**||Object  |        |                 | |
|student/school_enrollment/full_time_equivalency/fteid|INSERT|Number|10|Students.FteId|**The FTEID should be valid if provided.** If not provided, the FTEID will be set to the default value as defined under School Setup. The student's full-time equivalency ID.|
|student/school_enrollment/full_time_equivalency/name||String|80|Fte.Name|The student's full-time equivalency associated name.|



|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/addresses/physical** || OBJECT   |        |                 | This block is optional. However, if included, all related data must be provided. For example, if one attribute in the block is provided, such as Street, then the rest of the attributes in the block with the exception of grid location must be provided as well. |
| student/addresses/physical/street|INSERT, UPDATE|String | 60 |Students.Street       | The student's street address. |
| student/addresses/physical/city  |INSERT, UPDATE|String | 50 |Students.City         | The city element of the student's address.|
| student/addresses/physical/state_province|INSERT, UPDATE|String|2|Students.State    |The state/province element of the student's address.|
| student/addresses/physical/postal_code|INSERT, UPDATE|String|10|Students.Zip        |The zip/postal code element of the student's address.|
| student/addresses/physical/grid_location|INSERT, UPDATE|String|40|Students.Geocode  |The latitude/longitude coordinates of the student's physical address.|

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/addresses/mailing** | |  Object  |        |                 |             | This block is optional. However, if included, all related data must be provided. For example, if one attribute in the block is provided, such as street, then the rest of the attributes in the block with the exception of grid location must be provided as well.|
| student/addresses/mailing/street|INSERT, UPDATE|String|60|Students.Mailing_Street   |The student's mailing street address.|
| student/addresses/mailing/city|INSERT, UPDATE  |String|50|Students.Mailing_City     |The city element of the student's mailing address.|
| student/addresses/mailing/state_province|INSERT, UPDATE|String|2|Students.Mailing_State|The state/province element of the student's mailing address.|
| student/addresses/mailing/postal_code|INSERT, UPDATE|String|10|Students.Mailing_Zip |The zip/postal code element of the student's mailing address.|
| student/addresses/mailing/grid_location|INSERT, UPDATE|String|40|Students.Mailing_Geocode|The latitude/longitude coordinates of the student's mailing address.|

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/contact**       |     | Object   |        |                 |             |
| student/contact/emergency_contact_name1|INSERT, UPDATE|String|60|Students.Emerg_Contact_1|Person's Name of the student's Emergency Contact - Emergency_contact_name1 must be provided if Emergency_phone1 is provided.|
|student/contact/emergency_phone1|INSERT, UPDATE|String|30|Students.Emerg_Phone_1|The phone number of the student's emergency contact. - Emergency_phone1 must be provided if Emergency_contact_name1 is provided. |
|student/contact/emergency_contact_name2|INSERT, UPDATE|String|60|Students.Emerg_Contact_2|Emergency_contact_name2 must be provided if Emergency_phone2 is provided.|
|student/contact/emergency_phone2|INSERT, UPDATE|String|60|Students.Emerg_Phone_2|Emergency_phone2 must be provided if Emergency_contact_name2 is provided.|
|student/contact/guardian_email|INSERT, UPDATE|String|  |Students.GuardianEmail | The email of student's guardian.|
|student/contact/guardian_fax  |INSERT, UPDATE|String|30|Students.GuardianFax   | The fax number of student's guardian.|
|student/contact/mother        |INSERT, UPDATE|String|60|Students.Mother        | The name of student's mother.|
|student/contact/father        |INSERT, UPDATE|String|60|Students.Father        | The name of student's father.|
|student/contact/doctor_name   |INSERT, UPDATE|String|60|Students.Doctor_Name   | Doctor_phone must be provided if Doctor_name is provided.|
|student/contact/doctor_phone  |INSERT, UPDATE|String|30|Students.Doctor_Phone  |Doctor_name must be provided if Doctor_phone is provided.|

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/contact_info**        | Object   |        |                 |             |
| student/contact_info/email|INSERT, UPDATE|String|--|PSM_StudentContact.Email| The student's email contact.|

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/demographics** |      | Object   |        |                 |             |
|student/demographics/gender|INSERT, UPDATE|String| 2 |Students.Gender  |The student's gender - must only be {M, F}. M=Male, F=Female.|
|student/demographics/birth_date| INSERT, UPDATE|Date||Students.DOB     | The student's date of birth. **FORMAT: YYYY-MM-DD**|
|student/demographics/district_entry_date| INSERT, UPDATE|Date||Students.DistrictEntryDate|The date the student entered the district. **FORMAT: YYYY-MM-DD**|
|student/demographics/projected_graduation_year|INSERT, UPDATE|Long||Students.Sched_YearOfGraduation|The year the student is expected to graduate. This may change if the student does not pass or skips a grade.|

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/initial_enrollment** || Object   |        |                 |             |
|student/initial_enrollment/district_entry_date|INSERT, UPDATE|Date||Students.DistrictEntryDate|The student's district entry date. **FORMAT: YYYY-MM-DD**|
|student/initial_enrollment/district_entry_grade_level|INSERT, UPDATE|Numbe|10|Students.DistrictEntryGradeLevel|The student's district entry grade level.|
|student/initial_enrollment/school_entry_date|INSERT, UPDATE|Date||Students.SchoolEntryDate|The student's school entry date. **FORMAT: YYYY-MM-DD**|
|student/initial_enrollment/school_entry_grade_level|INSERT, UPDATE|Number|10|Students.SchoolEntryGradeLevel|The student's school entry grade level.|

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/phones**    |         | Object   |        |                 |             |
| student/phones/main   |         | Object   |        |                 |             |
|student/phones/main/number|INSERT, UPDATE|String| 30 |Students.Home_Phone| The student's home phone number.|

|  Attribute            | Actions |  Type    | Length | DataBase Column | Description |
| ----------------------| ------- | -------- | -------|---------------- | ----------- |
| **student/schedule_setup** |    | Object   |        |                 |             |
| student/schedule_setup/home_room|INSERT, UPDATE|String| 60 | Students.Home_Room     | The student's home room.|
| student/schedule_setup/next_school|INSERT, UPDATE|Number|10| Students.Next_School   | Note: Graduated school is a valid next school. The school number of a graduated school is 999999 and the grade of a student in a graduated school is 99.	The school the student is going to next.|
| student/schedule_setup/sched_next_year_grade|INSERT, UPDATE|Number|10|Students.Sched_NextYearGrade|Note: In other areas of PowerSchool, this field may be set to zero as a default value; however, zero can also be used as a valid grade level to indicate Kindergarten.	The grade level the student would be going to next year.|


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
