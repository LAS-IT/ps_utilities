# CHANGE LOG

## ToDo

- write example code - update_users update localized db extensions
- refactor student data errors with elegant assertions
- Student Creation (needed for LAS)
  - add LDAP enabled
  - add parent web_id
  - add parent web_password

## Changes

* **v1.0.3** - 2020-03-05
  - update dependencies
* **v1.0.2** - 2018-06-29
  - fixed local_id bug on create student
  - added data structure checks for badly formatted student data
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
