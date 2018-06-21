module PsUtilities

  module ApiEndpoints

    API_PATHS = {
      ws: '/ws/v1',
      ptg: '/powerschool-ptg-api/v2/',
      xte: '/ws/xte'
    }

    # get all the kids (first x anyway)
    # las-test.powerschool.com/ws/v1/district/student?q=school_enrollment.enroll_status==a&pagesize=500&page=2
    # or
    # las-test.powerschool.com/ws/v1/district/student?q=school_enrollment.enroll_status_code==0
    # {
    #     "students": {
    #         "@expansions": "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #         "@extensions": "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #         "student": [
    #             {
    #                 "id": 4916,
    #                 "local_id": 112406,
    #                 "student_username": "chens406",
    #                 "name": {
    #                     "first_name": "Siting",
    #                     "last_name": "CHEN"
    #                 },
    #                 "contact_info": {
    #                     "email": "chens406@las.ch"
    #                 }
    #             },
    #             {
    #                 "id": 4932,
    #                 "local_id": 112520,
    #                 "student_username": "jozwiap520",
    #                 "name": {
    #                     "first_name": "Patryk",
    #                     "last_name": "JOZWIAK"
    #                 },
    #                 "contact_info": {
    #                     "email": "jozwiap520@las.ch"
    #                 }
    #             }
    #         ]
    #     }
    # }
    # or more info on kids:
    # las-test.powerschool.com/ws/v1/district/student?q=school_enrollment.enroll_status==a&expansions=school_enrollment,contact,contact_info,schedule_setup
    #
    # get total number of kids active
    # las-test.powerschool.com/ws/v1/district/student/count?q=school_enrollment.enroll_status_code==0
    # {
    #     "resource": {
    #         "count": 423
    #     }
    # }
    #
    # get
    # las-test.powerschool.com/ws/v1/district/student?expansions=school_enrollment&q=student_username==eliassn237
    # {
    #     "students": {
    #         "@expansions": "demographics, addresses, alerts, phones, school_enrollment, ethnicity_race, contact, contact_info, initial_enrollment, schedule_setup, fees, lunch",
    #         "@extensions": "s_stu_crdc_x,activities,c_studentlocator,u_students_extension,u_studentsuserfields,s_stu_ncea_x,s_stu_edfi_x,studentcorefields",
    #         "student": {
    #             "id": 5999,          # dcid
    #             "local_id": 103237,  # student_id
    #             "student_username": "xxxxxx237",
    #             "name": {
    #                 "first_name": "Nadine",
    #                 "last_name": "xxxxxxx"
    #             }
    #         }
    #     }
    # }

    def initialize(api_credentials, options = {})
      self.client = Class.new(Powerschool::Client) do |klass|
        uri = api_credentials['base_uri'] || Powerschool::Client::BASE_URI
        klass.base_uri(uri)

        # options like `verify: false` (to disable ssl verification)
        options.each do |k, v|
          default_options.update({k => v})
        end
      end.new(api_credentials)
    end

    class << self
      [:get, :post, :put, :delete].each do |command|
        define_method(command.to_s) do |method, api, path = nil|
          if path.nil?
            path, api = api, nil
          end
          define_method(method) do |options = {}|
            return self.client.class.send(command, prepare_path(path.dup, api, options), self.client.options.merge(options))
          end
        end
      end
    end

    def prepare_path(path, api, options)
      options = options.dup
      options.each_pair do |key, value|
        regexp_path_option = /(:#{key}$|:#{key}([:&\/-_]))/
        if path.match(regexp_path_option)
          if value.blank?
            raise "Blank value for parameter '%s' in '%s'" % [key, path]
          end
          path.gsub!(regexp_path_option, "#{value}\\2")
          options.delete(key)
        end
      end
      if parameter = path.match(/:(\w*)/)
        raise "Missing parameter '%s' in '%s'. Parameters: %s" % [parameter[1], path, options]
      end
      if api
        path = (API_PATHS[api] + path).gsub('//', '/')
      end
      path
    end

    # retreive max_page_size from metadata. Defaults to 100
    def get_page_size(resource)
      @metadata ||= self.metadata()
      @metadata['%s_max_page_size' % resource.split('/').last.singularize] rescue 100
    end

    # Process every object for a resource.
    def all(resource, options = {}, &block)
      page_size = (options[:query][:pagesize] rescue nil) || get_page_size(resource)
      _options = options.dup
      _options[:query] ||= {}
      _options[:query][:pagesize] ||= page_size

      page = 1
      results = []
      begin
        _options[:query][:page] = page
        response = self.send(resource, _options)
        results = response.parsed_response || {}
        if !response.parsed_response
          if response.headers['www-authenticate'].match(/Bearer error/)
            raise response.headers['www-authenticate'].to_s
          end
        end

        if results.is_a?(Hash)
          plural = results.keys.first
          results = results[plural][plural.singularize] || []
        end
        if results.is_a?(Hash)
          # a rare(?) case has been observed where (in this case section_enrollment) did return a single
          # data object as a hash rather than as a hash inside an array
          results = [results]
        end
        results.each do |result|
          block.call(result, response)
        end
        page += 1
      end while results.any? && results.size == page_size
    end

    # client is set up per district so it returns only one district
    # for urls with parameters
    get :district, :ws, '/district'
    get :schools, :ws, '/district/school'
    get :teachers, :ws, '/staff'
    get :student, :ws, '/student/:student_id'
    get :students, :ws, '/student'
    get :school_teachers, :ws, '/school/:school_id/staff'
    get :school_students, :ws, '/school/:school_id/student'
    get :school_sections, :ws, '/school/:school_id/section'
    get :school_courses, :ws, '/school/:school_id/course'
    get :school_terms, :ws, '/school/:school_id/term'
    get :section_enrollment, :ws, '/section/:section_id/section_enrollment'

    # PowerTeacher Gradebook (pre Powerschool 10)
    get :assignment, :ptg, 'assignment/:id'
    post :post_section_assignment, :ptg, '/section/:section_id/assignment'
    put :put_assignment_scores, :ptg, '/assignment/:assignment_id/score'
    put :put_assignment_score, :ptg, '/assignment/:assignment_id/student/:student_id/score'

    # PowerTeacher Pro
    post :xte_post_section_assignment, :xte, '/section/assignment?users_dcid=:teacher_id'
    put :xte_put_assignment_scores, :xte, '/score'
    get :xte_section_assignments, :xte, '/section/assignment?users_dcid=:teacher_id&section_ids=:section_id'
    get :xte_section_assignment, :xte, '/section/assignment/:assignment_id?users_dcid=:teacher_id'
    get :xte_teacher_category, :xte, '/teacher_category'

    get :metadata, :ws, '/metadata'
    get :areas, '/ws/schema/area'
    get :tables, '/ws/schema/table'
    get :table_records, '/ws/schema/table/:table?projection=:projection'
    get :table_metadata, '/ws/schema/table/:table/metadata'
    get :area_table, '/ws/schema/area/:area/table'

    get :queries, '/ws/schema/query/api'

    def start_year
      offset = Date.today.month <= 6 ? -1 : 0
      year = self.client.api_credentials['start_year'] || (Date.today.year + offset)
    end

    # Special method to filter terms and find the current ones
    def current_terms(options, today = nil)
      terms = []
      today ||= Date.today.to_s(:db)
      self.all(:school_terms, options) do |term, response|
        if term['end_date'] >= today
          terms << term
        end
      end
      if terms.empty?
        options[:query] = {q: 'start_year==%s' % start_year}
        self.all(:school_terms, options) do |term, response|
          if term['end_date'] >= today
            terms << term
          end
        end
      end
      # now filter again for the start date and if there isn't one matching we have to return the most recent one
      in_two_weeks = (Date.parse(today) + 2.weeks).to_s(:db)
      active_terms = terms.select{|term| term['start_date'] <= in_two_weeks }
      if active_terms.any?
        return active_terms
      end
      return terms
    end

  end
end
