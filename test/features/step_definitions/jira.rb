And(/^a test execution with id "([^"]*)"$/) do |jira_id|
  set_environment_variable 'XRAY_TEST_EXECUTION', jira_id
  log.debug "Test execution: #{ENV['XRAY_TEST_EXECUTION']}"
end

And(/^no test execution exists$/) do
  set_environment_variable 'XRAY_TEST_EXECUTION', nil
  log.debug "Test execution: #{ENV['XRAY_TEST_EXECUTION']}"
end

Given(/^a environment "([^"]*)" with version "([^"]*)" and revision "([^"]*)" are defined in environment$/) do |environment, version, revision|
  set_environment_variable 'QAT_REPORTER_XRAY_BUILD_ENVIRONMENT', environment
  log.debug "Environment: #{ENV['QAT_REPORTER_XRAY_BUILD_ENVIRONMENT']}"
  set_environment_variable 'QAT_REPORTER_XRAY_BUILD_VERSION', version.to_s
  log.debug "Environment version: #{ENV['QAT_REPORTER_XRAY_BUILD_VERSION']}"
  set_environment_variable 'QAT_REPORTER_XRAY_BUILD_REVISION', revision.to_s
  log.debug "Environment revision: #{ENV['QAT_REPORTER_XRAY_BUILD_REVISION']}"
end