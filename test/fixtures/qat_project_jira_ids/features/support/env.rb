# Code coverage
require 'simplecov'
require 'qat/cucumber'
require 'qat/reporter/xray'

QAT::Reporter::Xray.configure do |c|
  c.project_key                = 'QAT'
  c.test_prefix                = 'TEST_'
  c.story_prefix               = 'STORY_'
  c.login_credentials          = ['joao.leal@readinessit.com', 'EuN0DCla9cr1H6isdKXSE712']
  c.cloud_xray_api_credentials = ['13F9B5CE7A344CACA80BCB06FC8227D4', '6dfa5149dfac2c9046a6278f262bd00b3af041366702ebfadda06e845693852f']
  c.jira_url                   = 'https://qadjoaoleal.atlassian.net'
  c.jira_type                  = 'cloud'
end

module Tests
  class Cucumber
    include QAT::Logger
    include Minitest::Assertions

    attr_writer :assertions

    def assertions
      @assertions ||= 0
    end
  end
end

World { ::Tests::Cucumber.new }