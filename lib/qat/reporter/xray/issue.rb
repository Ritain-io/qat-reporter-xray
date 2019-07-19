require 'rest-client'
require 'json'

module QAT
  module Reporter
    class Xray
      # QAT::Reporter::Xray::Issue represents an abstract Xray issue
      class Issue

        attr_reader :jira_id

        # Initializes Xray Publisher url and login information
        def initialize(jira_id = nil)
          @jira_id = jira_id
          if jira_id
            raise(InvalidIssueType, "The given issue '#{jira_id}' type does not correspond!") unless valid_test_execution?
          end
        end

        # Creates a issue
        def create(data)
          QAT::Reporter::Xray::Config.publisher.create_issue(data)
        end

        # Error returned when the the JIRA Issue does not correspond
        class InvalidIssueType < StandardError
        end
        # Error returned when publisher string is not known
        class PublisherNotKnownError < StandardError
        end

        private

        def valid_test_execution?
          base     = Publisher::Base.new
          response = JSON.parse(Publisher::Base::Client.new(base.base_url).get("/rest/api/2/issue/#{jira_id}", base.default_headers))
          if response.dig('fields', 'issuetype', 'name').eql? 'Test Execution'
            true
          else
            false
          end
        end
      end
    end
  end
end
