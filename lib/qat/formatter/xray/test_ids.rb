require 'cucumber/formatter/io'
require 'json'

module QAT
  module Formatter
    class Xray
      class TestIds
        include Cucumber::Formatter::Io

        def initialize(runtime, path_or_io, options)
          @io                 = ensure_io(path_or_io)
          @tags               = []
          @scenario_tags      = []
          @no_test_id         = {}
          @max_test_id        = 0
          @duplicate_test_ids = {}
          @test_id_mapping    = {}
          @options            = options
        end

        def before_feature(feature)
          @in_scenarios = false
        end

        def tag_name(tag_name)
          @scenario_tags << tag_name if @in_scenarios
        end

        def after_tags(tags)
          @in_scenarios = true unless @in_scenarios
        end

        def scenario_name(keyword, name, file_colon_line, source_indent)
          if @scenario_tags.any? { |tag| tag.match(/@id:(\d+)/) }
            id           = @scenario_tags.map { |tag| tag.match(/@id:(\d+)/) }.compact.first.captures.first.to_i
            @max_test_id = id if id > @max_test_id

            test_id_info = { name: name,
                             path: file_colon_line }

            if @test_id_mapping[id]
              if @duplicate_test_ids[id]
                @duplicate_test_ids[id] << test_id_info
              else
                @duplicate_test_ids[id] = [@test_id_mapping[id], test_id_info]
              end
            else
              @test_id_mapping[id] = test_id_info
            end

          else
            @no_test_id[name] = file_colon_line unless @scenario_tags.include?('@dummy_test')
          end
          @scenario_tags = []
        end

        def after_features(features)
          publish_result
          @io.flush
        end

        private

        def publish_result
          content = {
            max:       @max_test_id,
            untagged:  @no_test_id,
            mapping:   Hash[@test_id_mapping.sort],
            duplicate: Hash[@duplicate_test_ids.sort]
          }

          if @duplicate_test_ids.any?
            dups_info = @duplicate_test_ids.map do |id, dups|
              text = dups.map { |dup| "Scenario: #{dup[:name]} - #{dup[:path]}" }.join("\n")
              "TEST ID #{id}:\n#{text}\n"
            end

            duplicates_info = <<-TXT.gsub(/^\s*/, '')
          ------------------------------------
          Duplicate test ids found!
          ------------------------------------
          #{dups_info.join("\n")}
            TXT
            puts duplicates_info
          end

          @io.puts(content.to_json({
                                     indent:    ' ',
                                     space:     ' ',
                                     object_nl: "\n"
                                   }))
        end
      end
    end
  end
end