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
api_path = "/ws/v1/district/student"
options  = { query: { "q"=>"school_enrollment.enroll_status==a",
                      "pagesize"=>"500" } }
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


# get one kid
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ps_utilities.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
