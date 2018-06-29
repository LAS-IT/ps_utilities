# PsUtilities

Ruby wrapper for PowerSchool API interaction (& the OAuth2 authentication).

This code has good test coverage and we have put efforts to make its usage well documented & simply - espescially for common events, such a searching all students, creating and / or updating students profiles and retriving an individual's PS record.

The only external library in use in this code base is HTTParty - therefore, this code works with or without rails.  We at LAS use this code to sync hourly between OpenApply (using https://github.com/LAS-IT/openapply) and PowerSchool.

*A lot of effort has gone into discovering and documenting the PS API & collecting the scattered information - in order to effectively use the API (& extend this code base as necessary).*  Hopefully, the API documentation summary and examples will help others understand and use the PS API.

The original start for this code is from: https://github.com/TomK32/powerschool (although now very heavily refactored).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ps_utilities'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ps_utilities

## Change Log

[CHANGE_LOG.md](CHANGE_LOG.md)

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
# {:students:
#   [
#     {"id"=>4916, "local_id"=>112406, "student_username"=>"xxxx406", "name"=>{"first_name"=>"Xxxxxx", "last_name"=>"xxxxx"}},
#     {"id"=>5037, "local_id"=>112380, "student_username"=>"yyyyy380", "name"=>{"first_name"=>"Yyyyyy", "last_name"=>"YYYYY"}},
#     .....
#   ]
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

# get one kid - check the results of update - MUST use the ID (dcid)
params   = {id: 5999}
one      = ps.run(command: :get_one_student, params: {id: 5999} )
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

# if you try to create the same kid twice you get the following error result:
{"results"=>
  {"insert_count"=>0,
   "update_count"=>0,
   "delete_count"=>0,
   "result"=>
    {"client_uid"=>210987,
     "status"=>"ERROR",
     "action"=>"INSERT",
     "error_message"=>
      {"error"=>
        {"field"=>"student/local_id", "error_code"=>"INVALID_LOCAL_ID", "error_description"=>"Local ID already exists in the database and can not be used in an insert."}}}}}


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
