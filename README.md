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

- test create a duplicate user scenario
- write example code - update_users update localized db extensions
- Student Creation (needed for LAS)
  - add LDAP enabled
  - add parent web_id
  - add parent web_password
- add user_exists? - test create a duplicate user scenario
- add polite errors for bad data structures, when creating or updating students, ie fail nicely when: {students: {students: [{}]}} should be **params: {students: [{}]}**

## Change Log

* **v1.0.2** - 2018-??-??
  -
* **v1.0.1** - 2018-06-29
  - finished tests
  - added initial enrollment
  - Made ENV-Vars named the same as variables
* **v1.0.0** - 2018-06-28
  - example code notes
  - improve test coverage (and bug fix)
  - initialize api parameters changed
* **v0.3.2** - 2018-06-27 - cleanup and generalize
  - write gem docs
  - write example code - create_users
  - flexible usage of student database extensions added
* **v0.3.1** - 2018-06-26 -- compatible with v0.3.0
  - added pre-built student create and update as POST - basic fields default
  - Can update db extensions (for las - not yet elegant or generalized, but how to is documented in the code)
* **v0.3.0** - 2018-06-22 -- not compatible with v0.2.0 (prebuilt commands)
  - heavily refactored - recursively gets all students
  - updated / improved readme - with common api info (all collected into one spot)
* **v0.2.1** - 2018-06-21
  - internal refactoring - pushed accidentally before writing docs - oops
* **v0.2.0** - 2018-06-21 - not compatible with v0.1.0
  - update api - using api_path for clarity
* **v0.1.0** - 2018-06-21
  - get student counts and get all students (up to 500 kids) - no paging yet

## Usage

**To enable API login PowerSchool as an admin** and follow this path: *System>System Settings>Plugin Management Configuration>your plugin>Data_Provider_Configuration* after that is configured you can use the below code:

```ruby
require 'ps_utilities'

# INSTANTIATE
#############


# use parameters to configure powerschool
ps = PsUtilities::Connection.new(
     api_info: {
       base_uri: 'https://sample.powerschool.com/',
       auth_endpoint: '/oauth/access_token'},
     client_info: {
       client_id: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
       client_secret:  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'},
)

# BETTER STILL USE ENV VARS
# ENV['PS_BASE_URI'] = 'https://ps.school.k12/'         # (no default)
# ENV['PS_AUTH_ENDPOINT'] = '/oauth/access_token'       # (the default)
# ENV['PS_CLIENT_ID'] = '23qewrdfghjuy675434ertyui'     # (no default)
# ENV['PS_CLIENT_SECRET'] = '43ertfghjkloi9876trdfrdfg' # (no default)

# use ENV Vars and just do:
ps = PsUtilities::Connection.new
pp ps

# AUTHENTICATE against the powerschool api (this should happen automatically, but still good to do initially to avoid delays, etc)
ps.run(command: :authenticate)
# or
ps.run

# list of active students
kids     = ps.run( command: :get_all_active_students )
pp kids
# {"students"=>
#   {"@expansions"=> "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
#    "@extensions"=> "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
#    "student"=>
#     [
#       {"id"=>4916, "local_id"=>112406, "student_username"=>"xxxx406", "name"=>{"first_name"=>"Xxxxxx", "last_name"=>"xxxxx"}},
#       {"id"=>5037, "local_id"=>112380, "student_username"=>"yyyyy380", "name"=>{"first_name"=>"Yyyyyy", "last_name"=>"YYYYY"}},
#       .....
#     ]
#   }
# }

# get all active students with last_name starting with B
kids    = ps.run(command: :get_all_matching_students,
                  params: {last_name: "B*", status_code: 0})

data = [
  { id: 7337, student_id: 555807, email: "joey@las.ch",
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrcity: "Bex",
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcountry: "CH", transcriptaddrline2: "CP 108"} }
]
kids = ps.run(command: :update_students, params: {students: data })
# {"results"=>
#   {"insert_count"=>0,
#    "update_count"=>1,
#    "delete_count"=>0,
#    "result"=>
#     { "client_uid"=>555807,
#       "status"=>"SUCCESS",
#       "action"=>"UPDATE",
#       "success_message"=>{
#         "id"=>7337,
#         "ref"=>"https://las-test.powerschool.com/ws/v1/student/7337"
#       }
#     }
#   }
# }

# get one kid - check the results of update
params   = {username: "user237"}
one      = ps.run(command: :get_one_student, params: params )
# {"students"=>
#   {"@expansions"=>"demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
#    "@extensions"=> "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
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


# CREATE A SINGLE STUDENT ACCOUNT
# required fields are: student_id (chosen by the school), first_name, last_name, entry_date, exit_date, school_number, grade_level - many other fields are optional and available
data = { student_id: 555807, email: "joey@las.ch",
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
}
kids = ps.run(command: :create_student, params: {students: [data] })

# MAKE SEVERAL STUDENT ACCOUNTS
data = [
  { student_id: 555807, email: "joey@las.ch",
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
  },
  { student_id: 555808, email: "jack@las.ch",
    u_students_extension: { student_email: "jack@las.ch", preferredname: "jack"},
    u_studentsuserfields: { transcriptaddrline1: "A Rd.",
                            transcriptaddrzip: "1859", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Aigle",transcriptaddrcountry: "DE"}
  }
]
kids = ps.run(command: :create_students, params: {students: data })


# UPDATE A SINGLE STUDENT ACCOUNT
# required fields are: id (dcid) and student_id (local_id - chosen by the school)
# many other fields are available
# fields that can't be changed after creation (via api) include: id (dcid is set by the PS system) entry_date, exit_date, school_number, grade_level
data = { id: 7337, student_id: 555807, email: "joey@las.ch",
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
}
kids = ps.run(command: :update_student, params: {students: [data] })

# UPDATE SEVERAL STUDENT ACCOUNTS
data = [
  { id: 7337, student_id: 555807, email: "joey@las.ch",
    u_students_extension: { student_email: "joey@las.ch", preferredname: "Joey"},
    u_studentsuserfields: { transcriptaddrline1: "LAS", transcriptaddrline2: "CP 108",
                            transcriptaddrzip: "1858", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Bex", transcriptaddrcountry: "CH"}
  },,
  { id: 7338, student_id: 555808, email: "jack@las.ch",
    u_students_extension: { student_email: "jack@las.ch", preferredname: "jack"},
    u_studentsuserfields: { transcriptaddrline1: "A Rd.",
                            transcriptaddrzip: "1859", transcriptaddrstate: "VD",
                            transcriptaddrcity: "Aigle",transcriptaddrcountry: "DE"}
  }
]
kids = ps.run(command: :update_students, params: {students: data })

```

## PowerSchool API Notes

A collection of hard to find examples and needed info scattered over many locations

[PS_API_NOTES.md](PS_API_NOTES.md)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ps_utilities.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
