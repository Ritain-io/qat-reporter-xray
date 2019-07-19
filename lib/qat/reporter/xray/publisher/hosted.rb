require 'base64'
require 'zip'
require_relative 'base'

module QAT
  module Reporter
    class Xray
      module Publisher
        # QAT::Reporter::Xray::Publisher::Hosted integrator class
        class Hosted < Base

          # Posts the execution json results in Xray
          # @param results [String] Execution results
          def send_execution_results(results)
            Client.new(base_url).post('/rest/raven/1.0/import/execution', results.to_json, default_headers)
          end

          # Import Cucumber features files as a zip file via API
          # @param project_key [String] JIRA's project key
          # @param file_path [String]  Cucumber features files' zip file
          # @see https://confluence.xpand-it.com/display/public/XRAY/Importing+Cucumber+Tests+-+REST
          def import_cucumber_tests(project_key, file_path)
            headers = default_headers.merge({
                                              multipart: true,
                                              params:    {
                                                projectKey: project_key
                                              }
                                            })
            payload = { file: File.new(file_path, 'rb') }

            Client.new(base_url).post('/rest/raven/1.0/import/feature', payload, headers)
          end

          # Export Xray test scenarios to a zip file via API
          # @param keys [String] test scenarios
          # @param filter [String] project filter
          # @see https://confluence.xpand-it.com/display/public/XRAY/Exporting+Cucumber+Tests+-+REST
          def export_test_scenarios(keys, filter)
            params          = {
              keys: keys,
              fz:   true
            }

            params[:filter] = filter unless filter == 'nil'

            headers = default_headers.merge(params: params)

            rsp = RestClient.get("#{base_url}/rest/raven/1.0/export/test", headers)

            extract_feature_files(rsp)
          end
        end
      end
    end
  end
end