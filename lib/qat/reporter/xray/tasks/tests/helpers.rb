module QAT
  module Reporter
    class Xray
      # namespace for test ids utility methods and objects
      module Tests
        # helper methods for test id manipulation
        module Helpers
          # Tags all untagged scenarios present in the test id report
          #@param report [Tests::Report] test id report
          def tag_untagged(report)
            max_test_id = report.max_id
            untagged    = report.untagged

            if untagged.any?
              files = map_untagged(untagged)

              announce_changes(files)

              update_test_ids(files, max_test_id)
            else
              puts "There are no scenarios without test id. Last test id given was '@test##{max_test_id}'."
            end
          end

          private

          # Returns all files containing untagged scenarios and their respective scenario line
          #@param untagged [Array] list of untagged scenarios
          #@return [Array]
          def map_untagged(untagged)
            files = {}

            untagged.values.each do |file_colon|
              file, colon = file_colon.split(':')
              files[file] ||= []
              files[file] << colon.to_i
            end

            files
          end

          # Announces to STDOUT the files that will be changed (test ids added)
          #@param files [Array] list of files to change
          #@see TestIds::Helpers#map_untaged
          def announce_changes(files)
            puts "Giving test ids to scenarios:"
            puts files.to_json({
                                 indent:    ' ',
                                 space:     ' ',
                                 object_nl: "\n"
                               })
          end

          # Rewrites the untagged files adding the missing test ids
          #@param files [Array] list of files to change
          #@param max_test_id [Integer] current max test id
          def update_test_ids(files, max_test_id)
            #iterate in file to give test id
            begin
              file_lines = []
              files.each { |file, lines| max_test_id = rewrite_file(file, lines, max_test_id) }
            rescue
              path = File.join(Dir.pwd, 'public', 'test_ids_failed.feature')
              puts "Tag attribution failed! Check '#{path}' for more information!"
              File.write(path, file_lines.join)
            end
          end

          # Rewrites the target file in the identified lines.
          # Returns the max test id after the file update.
          #@param file [String] file to rewrite
          #@param lines [Array] lines to edit (add test id)
          #@param max_test_id [Integer] current max test id
          #@return [Integer]
          def rewrite_file(file, lines, max_test_id)
            norm_lines = lines.map { |line| line - 1 }
            file_path  = File.join(Dir.pwd, file)
            file_lines = File.readlines(file_path)

            norm_lines.size.times do
              line = norm_lines.shift
              puts "Editing file #{file} @ line #{line}."
              max_test_id = add_tags(file_lines, line, max_test_id)
            end

            File.write(file_path, file_lines.join)

            max_test_id
          end

          # Adds the test id tag to the identified line to edit
          # Returns the max test id after the file update.
          #@param file_lines [Array] Set of file lines
          #@param line [Integer] index of line to edit
          #@param max_test_id [Integer] current max test id
          #@return [Integer]
          def add_tags(file_lines, line, max_test_id)
            if file_lines[line - 1].match(/^\s*@\w+/)
              file_lines[line - 1] = "  #{file_lines[line - 1].strip} @id:#{max_test_id += 1}\n"
            else
              file_lines[line] = "  @id:#{max_test_id += 1}\n#{file_lines[line]}"
            end

            max_test_id
          end

          extend self
        end
      end
    end
  end
end