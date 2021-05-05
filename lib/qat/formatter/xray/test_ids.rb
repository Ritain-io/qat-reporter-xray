require 'cucumber/formatter/io'
require 'json'
require 'qat/formatter/test_ids'
require 'qat/formatter/helper'

module QAT
  module Formatter
    class Xray
      class TestIds <QAT::Formatter::TestIds
        include Cucumber::Formatter::Io
        include QAT::Formatter::Helper

        def initialize(config)
          @config             = config
          @no_test_id         = {}
          @max_test_id        = 0
          @duplicate_test_ids = {}
          @test_id_mapping    = {}
          @io                 = ensure_io(config.out_stream, config.error_stream)
          @ast_lookup         = ::Cucumber::Formatter::AstLookup.new(@config)
          config.on_event :test_case_started, &method(:on_test_case_started)
          config.on_event :test_run_finished, &method(:on_test_run_finished)
        end


        ###Override because of tag condition
        def scenario_name
          path = "#{@current_feature[:uri]}:#{@scenario[:line]}"
          scenario_tags= @scenario[:tags]
          if scenario_tags.any? { |tag| tag.match(/@id:(\d+)/) }
              id           = scenario_tags.map { |tag| tag.match(/@id:(\d+)/) }.compact.first.captures.first.to_i
            @max_test_id = id if id > @max_test_id

            test_id_info = { name: @scenario[:name],
                             path:  path}

            if @test_id_mapping[id]
              if @duplicate_test_ids[id]
                @duplicate_test_ids[id].find do |dup|
                  @exist = true if dup[:path]== test_id_info[:path]
                end
                @duplicate_test_ids[id] << test_id_info unless @exist
              else
                @duplicate_test_ids[id] = [@test_id_mapping[id], test_id_info] unless @test_id_mapping[id][:path] == test_id_info[:path]
              end
            else
              @test_id_mapping[id] = test_id_info
            end
          else
            @no_test_id[@scenario[:name]] = path unless scenario_tags.include?('@dummy_test')
          end
          @scenario[:tags] = []
        end

      end
    end
  end
end