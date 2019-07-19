require_relative 'publisher'

module QAT
  module Reporter
    class Xray
      # QAT::Reporter::Xray configuration module
      module Config
        class << self

          attr_accessor :project_key, :test_prefix, :story_prefix, :jira_url, :xray_default_api_url, :login_credentials, :publisher, :jira_type,
                        :cloud_xray_api_credentials, :xray_test_environment, :xray_test_version, :xray_test_revision, :xray_export_test_keys, :xray_export_test_filter

          # Default xray API url (Jira Cloud)
          DEFAULT_XRAY_URL = 'https://xray.cloud.xpand-it.com'

          # Default test tag prefix
          DEFAULT_TEST_PREFIX = 'TEST_'
          # Default story tag prefix
          DEFAULT_STORY_PREFIX = 'STORY_'

          # Returns the xray instanced type (hosted or cloud)
          def jira_type
            @jira_type
          end

          # Returns the jira url
          def jira_url
            @jira_url
          end

          # Returns the default xray jira url for cloud api
          def xray_default_api_url
            DEFAULT_XRAY_URL
          end

          # Returns the login credentials array could -> [username, password, apiToken]
          def login_credentials
            @login_credentials
          end

          # Returns the login credentials array for cloud api [client_id, client_secret]
          def cloud_xray_api_credentials
            @cloud_xray_api_credentials || nil
          end

          # Returns the test keys to export
          def xray_export_test_keys
            @keys || nil
          end

          # Returns the test filter to export
          def xray_export_test_filter
            @filter || nil
          end

          # Returns the project key value
          def project_key
            @project_key
          end

          # Returns the test tag prefix value
          def test_prefix
            @test_prefix || DEFAULT_TEST_PREFIX
          end

          # Returns the story tag prefix value
          def story_prefix
            @story_prefix || DEFAULT_STORY_PREFIX
          end

          # Returns the xray test environment value
          def xray_test_environment
            @xray_test_environment || get_env_from_qat_config
          end

          # Returns the xray test version value
          def xray_test_version
            @xray_test_version || get_version_from_qat_config
          end

          # Returns the xray test revision value
          def xray_test_revision
            @xray_test_revision || get_revision_from_qat_config
          end

          def publisher=(publisher)
            @publisher = publisher
          end

          def publisher
            @publisher
          end


          private

          def get_env_from_qat_config
            begin
              QAT.configuration.dig(:xray, :environment_name)
            rescue ArgumentError
              raise(NoEnvironmentDefined, 'JIRA\'s environment must be defined!')
            end
          end

          def get_version_from_qat_config
            begin
              QAT.configuration.dig(:xray, :version)
            rescue ArgumentError
              raise(NoVersionDefined, 'JIRA\'s version must be defined!')
            end
          end

          def get_revision_from_qat_config
            begin
              QAT.configuration.dig(:xray, :revision)
            rescue ArgumentError
              raise(NoRevisionDefined, 'JIRA\'s revision must be defined!')
            end
          end

          # Error returned when the QAT project has not defined the Jira Environment
          class NoEnvironmentDefined < StandardError
          end
          # Error returned when the QAT project has not defined the Jira Version
          class NoVersionDefined < StandardError
          end
          # Error returned when the QAT project has not defined the Jira Revision
          class NoRevisionDefined < StandardError
          end
        end
      end

      class << self
        # Configures the QAT::Formatter::Xray
        def configure(&block)
          yield Config

          QAT::Reporter::Xray::Config.publisher = QAT::Reporter::Xray::Publisher.const_get(QAT::Reporter::Xray::Config.jira_type.capitalize).new

          raise(ProjectKeyUndefinedError, 'JIRA\'s project key must be defined!') unless QAT::Reporter::Xray::Config.project_key
          raise(LoginCredentialsUndefinedError, 'JIRA\'s login credentials must be defined!') unless QAT::Reporter::Xray::Config.login_credentials
        end

        # Error returned when the the JIRA project key is not defined
        class ProjectKeyUndefinedError < StandardError
        end
        # Error returned when the the JIRA login credentials is not defined
        class LoginCredentialsUndefinedError < StandardError
        end
      end
    end
  end
end
