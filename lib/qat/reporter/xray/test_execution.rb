require 'rest-client'
require 'qat/logger'
require_relative 'issue'

module QAT
  module Reporter
    class Xray
      # QAT::Reporter::Xray::TestExecution represents a Xray Test Execution object
      class TestExecution < Issue
        include QAT::Logger

        # Creates a Test Execution issue in Jira
        def create(options = {})
          data               = test_execution_defaults.merge(options)
          response           = super(data)
          test_execution_key = JSON.parse(response)['key']
          log.info "Created test execution with key: '#{test_execution_key}', saving in 'XRAY_TEST_EXECUTION' env variable."
          ENV['XRAY_TEST_EXECUTION'] = test_execution_key
        end

        # Posts the execution json results in Xray
        def import_execution_results(execution_results, info = {})
          log.debug execution_results
          if jira_id
            issue_info                    = info.merge(default_update_headers(execution_results))
            issue_info[:testExecutionKey] = jira_id
          else
            issue_info = info.merge(default_create_headers(execution_results))
          end
          #If no test execution found, Xray will create one automatically
          QAT::Reporter::Xray::Config.publisher.send_execution_results(issue_info)
        end

        private

        def default_create_headers(execution_results)
          {
            info: {
                    summary:     "Execution of automated tests #{Time.now.strftime('%F %T')}",
                    description: 'This execution is automatically created when importing execution results from an external source',
                  }.merge(test_execution_info(execution_results))
          }.merge(execution_results)
        end

        def default_update_headers(execution_results)
          {
            info: test_execution_info(execution_results)
          }.merge(execution_results)
        end

        def test_execution_info(execution_results)
          {
            startDate:        execution_results[:tests].first[:start],
            finishDate:       execution_results[:tests].last[:finish],
            version:          QAT::Reporter::Xray::Config.xray_test_version.to_s,
            revision:         QAT::Reporter::Xray::Config.xray_test_revision.to_s,
            testEnvironments: [QAT::Reporter::Xray::Config.xray_test_environment]
          }
        end

        def test_execution_defaults
          {
            fields: {
              project:
                           {
                             key: QAT::Reporter::Xray::Config.project_key
                           },
              summary:     "Execution of automated tests #{Time.now.strftime('%F %T')}",
              description: 'Creation of automated Test Execution',
              issuetype:   {
                name: 'Test Execution'
              }
            }
          }
        end
      end
    end
  end
end
