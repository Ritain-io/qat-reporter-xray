require_relative 'helpers'

module QAT
  module Reporter
    class Xray
      # namespace for test ids utility methods and objects
      module Tests
        # the test id report wrapper
        class Report
          include Helpers

          attr_reader :path, :content

          def initialize(path)
            @path    = path
            @content = JSON.parse(File.read(path))
          end

          # Returns the report max test id
          def max_id
            @max_id ||= @content['max']
          end

          # Returns the report untagged tests information
          def untagged
            @untagged ||= @content['untagged']
          end

          # Returns the report test id mapping to scenarios information
          def mapping
            @mapping ||= @content['mapping']
          end

          # Returns the report duplicate test id information
          def duplicate
            @duplicate ||= @content['duplicate']
          end

          # Tags all untagged scenario with a test id
          def tag_untagged!
            tag_untagged(self)
          end
        end
      end
    end
  end
end