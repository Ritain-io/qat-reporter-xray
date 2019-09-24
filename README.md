[![Build Status](https://travis-ci.org/readiness-it/qat-reporter-xray.svg?branch=master)](https://travis-ci.org/readiness-it/qat-reporter-xray)

# QAT::Reporter::Xray

- Welcome to the QAT Reporter Xray Gem!
Before using this Gem it is necessary to have a Jira Xray repository Server or Cloud, configurated with:
    - Project with test issue types;
    - Project environment;
    - Project version. 

- For more information about Xray you can walkthrough into:
     - [Jira Xray Server](https://confluence.xpand-it.com/display/public/XRAY/Xray+Documentation+Home).
     - [Jira Xray Cloud](https://confluence.xpand-it.com/display/XRAYCLOUD/Xray+Cloud+Documentation+Home)
    
## Table of contents 
- This gem support interaction with Jira Xray Server and/or Cloud in the following ways:
  - **Import project features;**
  - **Import test executions;**
  - **Export jira tests;**
  - **Automatic generation of xray test ids.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qat-reporter-xray'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install qat-reporter-xray
    
# Usage
## Import project features into jira xray:
In order to use import features into jira xray it is necessary to run the following task:

 ```
 qat:reporter:xray:tests:import_features[username,password,url,jira_type,project_name]
 ```
  - ```Username``` and ```password``` are the credentials for the jira service, in case of 
 hosted(username, password) and in case of cloud service(client_id, client_secret).
  - ```Url``` - can be the hosted or cloud repository.
  - ```Jira type``` - can take two types: hosted or cloud. 
  - ```Project name``` - the project name created in jira xray service.
 
 This task runs two others before executing itself:
  ```
  qat:reporter:xray:tests:generate_test_ids
  qat:reporter:xray:tests:zip_features    
  ```
  These two tasks validates the test ids and zip the features to be ready for import. 

## Import test executions into jira xray:
In order to use import test executions into jira xray it is necessary to have the following configuration 
within the file ```env.rb``` on path ```"features/support/"``` (if file does not exist it must be created):

```
require 'minitest'
require 'qat/reporter/xray'

QAT::Reporter::Xray.configure do |c|
  c.project_key  = 'project key'
  c.test_prefix  = 'test prefix'
  c.story_prefix = 'story prefix'
  c.login_credentials = ['username/client_id', 'password/client_secret', 'api_token']
  c.jira_type = 'hosted or cloud' 
  c.jira_url = 'hosted or cloud url'
  c.xray_test_environment = 'environment defined in jira service'
  c.xray_test_version = 'version defined in jira service'
  c.xray_test_revision = 'revision defined in jira service'
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
```
If this configuration is not set:
```
c.xray_test_environment = 'environment defined in jira service'
c.xray_test_version = 'version defined in jira service'
c.xray_test_revision = 'revision defined in jira service'
```

There must be a file ```xray.yml``` on the path ```"config/dummy/"``` that configure the environment, version and revision throught environment variables:
```
environment_name: dummy
version: 1.0
revision: 1.0
```
After that it is necessary to have test scenario to import the result:
```
@STORY_PROJECT_KEY-7 @some_tag @foo @bar
    Feature: Dummy feature 2

    @TEST_PROJECT_KEY-1 @other_tag @scenario1
    Scenario: scenario 2.1
        Given some conditions
        When some actions are made
        Then a result is achieved
```

Then run the command to generate the output of the test to be imported, this output will be generated into the paste public of the project:
```
cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json
```
## Export jira xray tests into project:
In order to use export jira xray tests into project it is necessary to run the following task:

 ```
 qat:reporter:xray:tests:export_xray_test_scenarios[username,password,url,jira_type,test_keys,project_filter]
 ```
 - ```Username``` and ```password``` are the credentials for the jira service, in case of 
  hosted(username, password) and in case of cloud service(client_id, client_secret).
 - ```Url``` - can be the hosted or cloud repository;
 - ```Jira type``` - can take two types: hosted or cloud;
 - ```Test keys``` - the keys of the tests to be exported;
 - ```Project filter``` - projects filters.
 
## Automatic generation of xray test ids:
In order to use automatic generation of xray test ids it is necessary to run the following task:
this task generates ids of test scenarios in a project without test ids:
```
qat:reporter:xray:tests:generate_test_ids
```
## Automatic report of xray test ids:
In order to use automatic report of xray test ids it is necessary to run the following task:
this task gives a report of test ids in test scenarios in a project without test ids:
```
qat:reporter:xray:tests:report_test_ids
```

# Documentation

- [API documentation](https://readiness-it.github.io/qat-reporter-xray/)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/readiness-it/qat-report-xray. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the QAT::Reporter::Xray project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/readiness-it/qat-reporter-xray/blob/master/CODE_OF_CONDUCT.md). 
