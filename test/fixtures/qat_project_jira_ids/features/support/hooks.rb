#-*- encoding : utf-8 -*-
require 'vcr'

AfterConfiguration do
  STDOUT.puts "USING VCR CASSETTE '#{ENV['VCR_CASSETTE_NAME']}'"
  VCR.configure do |config|
    config.cassette_library_dir = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cassettes')
    config.hook_into :webmock
    config.default_cassette_options = {allow_unused_http_interactions: false, decode_compressed_response: true, record: :none}
  end

  VCR.eject_cassette&.tap do |cassette|
    puts "CLOSED VCR CASSETTE '#{cassette.name}' -> #{cassette.file}"
  end
  VCR.insert_cassette(ENV['VCR_CASSETTE_NAME']).tap{|i| STDOUT.puts i.file}
end

at_exit do
  VCR.eject_cassette&.tap do |cassette|
    puts "CLOSED VCR CASSETTE '#{cassette.name}' -> #{cassette.file}"
  end
end
#
# Around do |scenario, block|
#   # Your code here
#   #
#   VCR.configure do |config|
#     config.cassette_library_dir = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cassettes')
#     config.hook_into :webmock
#   end
#
#   VCR.use_cassette(scenario.name.downcase.parameterize, record: :new_episodes) do
#     block.call
#   end
#
# end

# After do |scenario|
#   sleep 30
# end

# AfterStep do |step|
#   # Your code here
# end