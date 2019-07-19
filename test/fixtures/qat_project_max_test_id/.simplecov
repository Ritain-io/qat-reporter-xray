# -*- encoding : utf-8 -*-
# Code coverage
require 'simplecov-json'
require 'simplecov-rcov'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]

SimpleCov.start do
  coverage_dir(ENV['SIMPLECOV_COVERAGE_DIR'])
  command_name("'aruba_#{::File.basename(::File.dirname(__FILE__))}_#{$$}' inception tests")
  profiles.delete(:root_filter)
  filters.clear
  add_filter do |src|
    src.filename !~ /#{ENV['SIMPLECOV_EVAL_DIR']}/
  end
end