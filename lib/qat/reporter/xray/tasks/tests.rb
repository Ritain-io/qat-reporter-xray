#!/usr/bin/env rake
#encoding: utf-8
require 'cucumber'
require 'cucumber/rake/task'
require 'rake/testtask'
require 'json'
require 'fileutils'
require 'awesome_print'
require 'fileutils'
require 'active_support/core_ext/string/inflections'
require_relative '../../../formatter/xray/test_ids'
require_relative 'tests/report'
require_relative 'tests/helpers'

namespace :qat do
  namespace :reporter do
    namespace :xray do
      namespace :tests do
        # Run a rake task by name
        def run_task!(task_name)
          begin
            Rake::Task["qat:reporter:xray:tests:#{task_name}"].invoke
          rescue SystemExit => exception
            exitstatus = exception.status
            @kernel.exit(exitstatus) unless exitstatus == 0
          end
        end

        desc 'Generates the test id report in JSON'
        task :report_test_ids do
          FileUtils.mkdir('public') unless File.exists?(File.join(Dir.pwd, 'public'))
          ENV['CUCUMBER_OPTS'] = nil
          Cucumber::Rake::Task.new('test_ids', 'Generates test ids as tags for tests without test id') do |task|
            task.bundler       = false
            task.fork          = false
            task.cucumber_opts = ['--no-profile',
                                  '--dry-run',
                                  '--format', 'QAT::Formatter::Xray::TestIds',
                                  '--out', 'public/xray_test_ids.json']
          end.runner.run
        end

        desc 'Validates the existing test ids and checks for duplicates'
        task :validate_test_ids do
          run_task!('report_test_ids')
          #read json file
          file_path = File.realpath(File.join(Dir.pwd, 'public', 'xray_test_ids.json'))
          report    = QAT::Reporter::Xray::Tests::Report.new(file_path)

          exit(1) if report.duplicate.any?
        end

        desc 'Generates test ids as tags for tests without test id'
        task :generate_test_ids do
          run_task!('report_test_ids')
          #read json file
          file_path = File.realpath(File.join(Dir.pwd, 'public', 'xray_test_ids.json'))
          report    = QAT::Reporter::Xray::Tests::Report.new(file_path)

          report.tag_untagged!
        end

        desc 'Generate features zip file to import in Xray'
        task :zip_features do
          require 'zip'

          file_mask     = File.join('features', '**', '*.feature')
          feature_files = Dir.glob(file_mask)
          puts feature_files

          zipfile_name = 'features.zip'

          FileUtils.rm_f(zipfile_name) if File.exists?(zipfile_name)

          Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
            feature_files.each do |file|
              zipfile.add(file, file)
            end
          end
        end

        # Validates the import task arguments
        def validate_import_args(args)
          [:xray_username, :jira_url, :jira_type, :project_key].each do |key|
            raise ArgumentError.new "No #{key.to_s.humanize} was provided" unless args[key]
          end
        end

        desc 'Import Cucumber tests to Xray'
        task :import_features, [:xray_username, :jira_url, :jira_type, :project_key, :file_path] do |_, args|
          run_task!('generate_test_ids')
          run_task!('zip_features')

          require 'qat/reporter/xray'

          file_path = args.delete(:file_path) || 'features.zip'

          validate_import_args(args)
          project_key = args[:project_key] or raise ArgumentError.new 'No project key was provided'
          login_credentials = [args[:xray_username], ENV['JIRA_PASSWORD']] or raise ArgumentError.new 'No login credentials were provided'
          jira_type = args[:jira_type] or raise ArgumentError.new 'No jira type key was provided'
          jira_url = args[:jira_url] or raise ArgumentError.new 'No jira url key was provided'

          QAT::Reporter::Xray.configure do |c|
            c.project_key                = project_key
            c.login_credentials          = login_credentials
            c.cloud_xray_api_credentials = login_credentials if jira_type.eql? 'cloud'
            c.jira_type                  = jira_type
            c.jira_url                   = jira_url
          end

          QAT::Reporter::Xray::Config.publisher.import_cucumber_tests(project_key, file_path)
        end

        desc 'Export Xray test scenarios '
        task :export_xray_test_scenarios, [:xray_username, :jira_url, :jira_type, :project_key, :keys, :filter] do |_, args|

          require 'qat/reporter/xray'

          project_key = args[:project_key] or raise ArgumentError.new 'No project key was provided'
          login_credentials = [args[:xray_username], ENV['JIRA_PASSWORD']] or raise ArgumentError.new 'No login credentials were provided'
          jira_type = args[:jira_type] or raise ArgumentError.new 'No jira type was provided'
          jira_url = args[:jira_url] or raise ArgumentError.new 'No jira url was provided'
          xray_export_test_filter = args[:filter] or raise ArgumentError.new 'No filter key was provided'
          xray_export_test_keys = args[:keys] or raise ArgumentError.new 'No test issue key was provided'

          QAT::Reporter::Xray.configure do |c|
            c.project_key                = project_key
            c.login_credentials          = login_credentials
            c.cloud_xray_api_credentials = login_credentials if jira_type.eql? 'cloud'
            c.jira_type                  = jira_type
            c.jira_url                   = jira_url
            c.xray_export_test_filter    = xray_export_test_filter
            c.xray_export_test_keys      = xray_export_test_keys
          end

          QAT::Reporter::Xray::Config.publisher.export_test_scenarios(xray_export_test_keys, xray_export_test_filter)
        end
      end
    end
  end
end