require 'rest-client'
require 'json'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'
require 'qat/logger'

module QAT
  module Reporter
    class Xray
      # QAT::Reporter::Xray::Publisher integrator module
      module Publisher
        # QAT::Reporter::Xray::Publisher::Base integrator class
        class Base
          include QAT::Logger

          attr_reader :base_url, :default_headers, :login_credentials, :default_cloud_api_url, :cloud_xray_api_credentials

          # Initializes Xray Publisher url and login information
          def initialize
            @base_url                   = QAT::Reporter::Xray::Config.jira_url
            @login_credentials          = QAT::Reporter::Xray::Config.login_credentials
            @default_cloud_api_url      = QAT::Reporter::Xray::Config.xray_default_api_url
            @cloud_xray_api_credentials = QAT::Reporter::Xray::Config.cloud_xray_api_credentials
          end

          # Creates a Jira issue
          def create_issue(data)
            Client.new(base_url).post('/rest/api/2/issue', data.to_json, default_headers)
          end


          # Get the default headers for Xray ('password' in Xray API is password)
          def default_headers
            headers = if QAT::Reporter::Xray::Config.jira_type == 'cloud'
                        auth_headers_jira_cloud
                      else
                        auth_headers
                      end
            {
              'Content-Type': 'application/json'
            }.merge(headers)
          end


          private
          # Authentication header for xray, Basic authentication done with: username, password
          def auth_headers
            username = login_credentials[0]
            password = login_credentials[1]
            {
              Authorization: "Basic #{::Base64::encode64("#{username}:#{password}").delete("\n")}"
            }
          end

          # Authentication header for jira, Basic authentication done with: username, apiToken
          def auth_headers_jira_cloud
            username  = login_credentials[0]
            api_token = login_credentials[2]
            {
              Authorization: "Basic #{::Base64::encode64("#{username}:#{api_token}").delete("\n")}"
            }
          end

          #Gets a zip file from a response and extracts features to 'Feature' folder
          def extract_feature_files(rsp)
            Zip::InputStream.open(StringIO.new(rsp)) do |io|
              while entry = io.get_next_entry
                entry_path = File.join('features', entry.name)
                log.info 'Feature ' + entry.name + ' was found, extracting...'
                entry.extract(File.join(Dir.pwd, entry_path)) unless File.exist?(entry_path)
              end
            end
              #See https://github.com/rubyzip/rubyzip#notice-about-zipinputstream
          rescue Zip::GPFBit3Error
            Tempfile.open do |file|
              File.write(file.path, rsp)

              Zip::File.open(file.path) do |zip_file|
                # Handle entries one by one
                zip_file.each do |entry|
                  # Extract to file/directory/symlink
                  log.info 'Feature ' + entry.name + ' was found, extracting...'
                  entry_path = File.join('features', entry.name)
                  entry.extract(entry_path)
                end
              end
            end
          end

          # REST Base Client implementation
          class Client
            include QAT::Logger

            # Service Unavailable Error class
            class ServiceUnavailableError < StandardError
            end
            # Connection Error class
            class ConnectionError < StandardError
            end

            # No Connection Error class
            class NoConnectionFound < StandardError
            end

            attr_reader :base_uri

            # Returns a new REST Base Client
            # @return [RestClient::Response]
            def initialize(base_uri)
              #sets the ip:port/base_route
              @base_uri = case base_uri
                            when Hash
                              URI::HTTP.build(base_uri).to_s
                            when URI::HTTP
                              base_uri.to_s
                            when String
                              base_uri
                            else
                              raise ArgumentError.new "Invalid URI class: #{base_uri.class}"
                          end
            end

            [:put, :post, :get, :delete, :patch].each do |operation|
              define_method operation do |url, *args|
                final_url = base_uri + url

                log_request operation, final_url, args
                begin
                  response = RestClient.method(operation).call(final_url, *args)
                  log_response response
                  validate response
                rescue RestClient::ExceptionWithResponse => e
                  log.error e.response
                  raise NoConnectionFound.new ('Jira was not found!!!')
                rescue => exception
                  log.error "#{exception.class} #{exception.message.to_s}"
                  raise NoConnectionFound.new ('Jira was not found!!!')
                end
              end
            end

            protected

            # Validates the response and raises a HTTP Error
            #@param response [RestClient::Response] response
            def validate(response)
              error_klass = case response.code
                              when 400 then
                                Error::BadRequest
                              when 401 then
                                Error::Unauthorized
                              when 403 then
                                Error::Forbidden
                              when 404 then
                                Error::NotFound
                              when 405 then
                                Error::MethodNotAllowed
                              when 409 then
                                Error::Conflict
                              when 422 then
                                Error::Unprocessable
                              when 500 then
                                Error::InternalServerError
                              when 502 then
                                Error::BadGateway
                              when 503 then
                                Error::ServiceUnavailable
                            end

              raise error_klass.new response if error_klass
              response
            end

            # Logs the request information
            #@param operation [String] HTTP operation called
            #@param url [String] target URL
            #@param args [String] request arguments
            #@see RestClient#get
            def log_request(operation, url, args)
              log.info { "#{operation.upcase}: #{url}" }

              args.each do |options|
                log_http_options options
              end
            end

            # Logs the received response
            #@param response [RestClient::Response] response
            def log_response(response)
              log.info "Response HTTP #{response.code} (#{response.body})"

              log_http_options({ headers: response.headers.to_h,
                                 body:    response.body }.select { |_, value| !value.nil? })
            end

            # Logs the request's HTTP options
            #@param options [Hash|String] http options to log
            def log_http_options(options)
              if log.debug?
                temp = if options.is_a?(String)
                         { payload: JSON.parse(options) }
                       else
                         options.map do |k, v|
                           if k == :body
                             begin
                               [k, JSON.pretty_generate(JSON.parse(v))]
                                 #if body is not JSON by some unknown reason, we still want to print
                             rescue JSON::ParserError
                               [k, v]
                             end
                           else
                             [k, v]
                           end
                         end.to_h
                       end

                temp.each do |key, value|
                  log.debug "#{key.to_s.humanize}:"
                  log.debug value
                end
              end
            end

          end
        end
      end
    end
  end
end