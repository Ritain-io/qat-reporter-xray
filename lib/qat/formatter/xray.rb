require 'cucumber/formatter/io'
require 'json'
require 'fileutils'
require 'qat/logger'
require 'time'
require 'base64'
require_relative '../reporter/xray/config'
require_relative '../reporter/xray/test_execution'
require 'qat/formatter/helper'

module QAT
  # Namespace for custom Cucumber formatters and helpers.
  #@since 0.1.0
  module Formatter
    # Namespace for Xray formatter
    #@since 1.0.0
    class Xray
      include ::Cucumber::Formatter::Io
      include QAT::Logger
      include QAT::Formatter::Helper

      def initialize(config)
        @config         = config
        @io             = ensure_io(config.out_stream, config.error_stream)
        @ast_lookup     = ::Cucumber::Formatter::AstLookup.new(config)
        @feature_hashes = []
        config.on_event :test_case_started, &method(:on_test_case_started)
        config.on_event :test_case_finished, &method(:on_test_case_finished)
        config.on_event :test_run_finished, &method(:on_test_run_finished)
        @tests = []
      end

      #@api private
      def tag_name(tag_name)
        @test_jira_id = tag_name.to_s.split('_')[1] if tag_name.match(test_tag_regex)
      end

      #@api private
      def on_test_case_started(event)
        return if @config.dry_run?
        @row_number = nil
        test_case   = event.test_case
        build(test_case, @ast_lookup)
        @current_scenario = @scenario

        @exception = nil

        @start_time   = Time.now
        @evidences    = []
        @file_counter = 0
        @current_scenario[:tags].each do |tag|
          tag_name tag
        end

      end

      #@api private
      def on_test_case_finished event
        return if @config.dry_run?
        _test_case, result = *event.attributes
        # When jira type is cloud the test result string must be different (accordingly with xray api)
        test_status = if result.passed?
                        jira_type == 'cloud' ? 'PASSED' : 'PASS'
                      elsif result.failed?
                        jira_type == 'cloud' ? 'FAILED' : 'FAIL'
                      else
                        'NO RUN'
                      end

        @end_time = Time.now

        comment = result.respond_to?(:exception) ? build_exception(result.exception) : ''

        log.warn 'Jira ID is not defined!' unless @test_jira_id
        if @examples_values
          save_current_scenario_outline(test_status, comment)
        else
          save_current_scenario(test_status, comment)
        end

      end


      def on_test_run_finished _event
        return if @config.dry_run?
        publish_result
      end


      def embed(src, mime_type, label)


        data = if File.file?(src)
                 File.open(src) do |file|
                   Base64.strict_encode64(file.read)
                 end
               elsif src =~ /^data:image\/(png|gif|jpg|jpeg);base64,/
                 src
               else
                 Base64.strict_encode64(src)
               end

        ext = mime_type.split('/').last

        file_name = if File.file?(src)
                      File.basename(src)
                    elsif label.to_s.empty?
                      "file_#{@file_counter += 1}.#{ext}"
                    else
                      "#{label}.#{ext}"
                    end

        @evidences << { data: data, filename: file_name, contentType: mime_type }
      end

      private

      def jira_type
        QAT::Reporter::Xray::Config.jira_type
      end

      def test_prefix
        QAT::Reporter::Xray::Config.test_prefix
      end

      def project_key
        QAT::Reporter::Xray::Config.project_key
      end

      def test_tag_regex
        /@#{test_prefix}(#{project_key}-\d+)/
      end

      def build_exception(exception)
        "#{exception.message} (#{exception.class})\n#{exception.backtrace.join("\n")}"
      end

      def save_current_scenario(status, comment = '')
        test_info             = {
          testKey: @test_jira_id,
          start:   @start_time.iso8601,
          finish:  @end_time.iso8601,
          comment: comment,
          status:  status
        }
        test_info[:evidences] = @evidences unless @evidences.empty?
        @tests << test_info
      end

      def save_current_scenario_outline(status, comment = '')
        if @tests.any? { |test| test[:testKey] == @test_jira_id }
          outline = @tests.select { |test| test[:testKey] == @test_jira_id }.first

          outline[:finish] = @end_time.iso8601
          unless outline[:status] == 'FAIL' || outline[:status] == 'FAILED'
            outline[:status]  = status
            outline[:comment] = comment
          end
          outline[:examples] << status

          @tests.delete_if { |test| test[:testKey] == @test_jira_id }
          @tests << outline
        else
          @tests << {
            testKey:  @test_jira_id,
            start:    @start_time.iso8601,
            finish:   @end_time.iso8601,
            comment:  comment,
            status:   status,
            examples: [
                        status
                      ]
          }
          if @tests.is_a? Array
            @tests.first[:evidences] = @evidences unless @evidences.empty?
          else
            @tests[:evidences] = @evidences unless @evidences.empty?
          end

        end
      end

      # Writes results to a JSON file
      def publish_result
        content = {
          tests: @tests
        }
        @io.puts(JSON.pretty_generate(content))

        jira_id = ENV['XRAY_TEST_EXECUTION'].to_s

        if jira_id.empty?
          log.warn 'Importing Test results to a new Test Execution.'
          jira_id = nil
        else
          log.info "Importing Test results to Test Execution '#{jira_id}'."
        end

        QAT::Reporter::Xray::TestExecution.new(jira_id).import_execution_results(content)

      end
    end
  end
end