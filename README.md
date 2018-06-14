# PsUtilities

Ruby wrapper for Powerschool API interaction - without using rails dependencies.

This uses oauth2 to connection to the Powerschool API.

This code is heavily refactored code from: https://github.com/LAS-IT/powerschool_tomk32

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ps_utilities'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ps_utilities

## Usage

```ruby
require 'ps_utilities'

# INSTANTIATE
#############
# Required ENV_Vars - found at:
# System>System Settings>Plugin Management Configuration>your plugin>Data_Provider_Configuration
# ENV['PS_URL'] = 'https://ps.school.k12/'              # (no default)
# ENV['PS_AUTH_ENDPOINT'] = '/oauth/access_token'       # (the default)
# ENV['PS_CLIENT_ID'] = '23qewrdfghjuy675434ertyui'     # (no default)
# ENV['PS_CLIENT_SECRET'] = '43ertfghjkloi9876trdfrdfg' # (no default)
# ENV['PS_ACCESS_TOKEN'] = nil                          # (not recommended)
powerschool = PsUtilities::Connection.new

# or use parameters
powerschool = PsUtilities::Connection.new(
     { base_uri: 'https://ps.school.k12/',
       auth_endpoint: '/oauth/access_token',
       client_id: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
       client_secret:  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
     }
)
pp powerschool
# BEFORE AUTHENTATION
# @credentials=
#  {:base_uri=>"https://las-test.powerschool.com",
#   :auth_endpoint=>"/oauth/access_token",
#   :client_id=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   :client_secret=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"},
# @options=
#  {:headers=>{"User-Agent"=>"Ruby Powerschool", "Accept"=>"application/json", "Content-Type"=>"application/json"}}>


# see connection class connection info
# run with no params - just authenticates (gets token)
powerschool.run
pp powerschool
# AFTER AUTHENTICATION - notice: token_expires (field)
# @credentials=
#  {:base_uri=>"https://las-test.powerschool.com",
#   :auth_endpoint=>"/oauth/access_token",
#   :client_id=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   :client_secret=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   :token_expires=>2018-02-18 16:47:28 +0200,
#   :access_token=>"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"},
# @options=
#  {:headers=>
#    {"User-Agent"=>"Ruby Powerschool",
#     "Accept"=>"application/json",
#     "Content-Type"=>"application/json",
#     "Authorization"=>"Bearer xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"}}>

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ps_utilities.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
