require_relative 'base'
require 'zip'

module QAT
  module Reporter
    class Xray
      module Publisher
        # QAT::Reporter::Xray::Publisher::Cloud integrator class
        class Cloud < Base

          # Posts the execution json results in Xray
          def send_execution_results(results)
            headers = { 'Content-Type': 'application/json' }.merge(auth_token)
            Client.new(default_cloud_api_url).post('/api/v1/import/execution', results.to_json, headers)
          end

          # Get the Authorization Token based on client_id & client_secret (ONLY FOR CLOUD XRAY)
          def auth_token
            return @auth_token if @auth_token

            client_id         = cloud_xray_api_credentials[0]
            client_secret     = cloud_xray_api_credentials[1]
            auth_header_cloud = {
              client_id:     client_id,
              client_secret: client_secret
            }

            response    = Client.new(default_cloud_api_url).post('/api/v1/authenticate', auth_header_cloud).body
            bearer      = JSON.parse(response)
            @auth_token = {
              Authorization: "Bearer #{bearer}"
            }
          end

          # Import Cucumber features files as a zip file via API
          # @param project_key [String] JIRA's project key
          # @param file_path [String]  Cucumber features files' zip file
          # @see https://confluence.xpand-it.com/display/XRAYCLOUD/Importing+Cucumber+Tests+-+REST
          def import_cucumber_tests(project_key, file_path, project_id = nil)
            headers = auth_token.merge({
                                         multipart: true,
                                         params:    {
                                           projectKey: project_key,
                                           projectId:  project_id,
                                           source:     project_key
                                         }
                                       })
            payload = { file: File.new(file_path, 'rb') }

            Client.new(default_cloud_api_url).post('/api/v1/import/feature', payload, headers)
          end

          # Export Xray test scenarios to a zip file via API
          # @param keys [String] test scenarios
          # @param filter [String] project filter
          # @see https://confluence.xpand-it.com/display/XRAYCLOUD/Exporting+Cucumber+Tests+-+REST
          def export_test_scenarios(keys, filter)
            params          = {
              keys: keys,
            }
            params[:filter] = filter unless filter == 'nil'

            headers = auth_token.merge(params: params)

            log.info "Exporting features from: #{default_cloud_api_url}/api/v1/export/cucumber"
            rsp = RestClient.get("#{default_cloud_api_url}/api/v1/export/cucumber", headers)

            extract_feature_files(rsp)
          end
        end
      end
    end
  end
end