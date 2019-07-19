require 'rest-client'
require_relative 'issue'

module QAT
  module Reporter
    class Xray
      # QAT::Reporter::Xray::TestExecution represents a Xray Test Execution object
      class Test < Issue

        # Creates a Test issue in Jira
        def create(options = {})
          data     = defaults.merge(options)
          response = super(data)
          test_key = JSON.parse(response)['key']
          log.info "Created test with key: '#{test_key}'."
        end

        private
        def defaults
          {
            fields: {
              project:
                                 {
                                   key: QAT::Reporter::Xray::Config.project_key
                                 },
              summary:           "Execution of automated tests #{Time.now.strftime('%F %T')}",
              description:       'Creation of automated Test',
              issuetype:         {
                name: 'Test'
              },
              customfield_10200: {
                value: 'Cucumber'
              },
              customfield_10201: {
                value: 'Scenario'
              },
              customfield_10202: 'customfield_10202'
            }
          }
        end
      end
    end
  end
end
