#encoding: utf-8
# require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'qat', 'version.rb'))

Gem::Specification.new do |gem|
  gem.name        = 'qat-reporter-xray'
  gem.version     = '6.0.1'
  gem.summary     = %q{Utility for Test Reports in Jira Xray.}
  gem.description = <<-DESC
  QAT Reporter Xray bellong to the QAT-Reporter collection of tools and is intended
  for importing test report information in Jira.
  DESC
  gem.email    = 'qatoolkit@readinessit.com'
  gem.homepage = 'https://www.readinessit.com'

  gem.metadata    = {
      'source_code_uri'   => 'https://github.com/readiness-it/qat-reporter-xray'
  }
  gem.authors = ['QAT']
  gem.license = 'GPL-3.0'

  extra_files = %w[LICENSE]
  gem.files   = Dir.glob('{lib}/**/*') + extra_files

  gem.required_ruby_version = '~> 2.3'

  # Development dependencies
  gem.add_development_dependency 'vcr', '~> 5.0', '>= 5.0.0'
  gem.add_development_dependency 'webmock', '~> 3.6', '>= 3.6.0'
  gem.add_development_dependency 'aruba', '~> 0.14', '>= 0.14.9'
  gem.add_development_dependency 'qat-devel', '~> 6.0'
  gem.add_development_dependency 'qat-cucumber', '~> 6.0'

  # GEM dependencies
  gem.add_dependency 'qat-logger'
  gem.add_dependency 'rest-client'
  gem.add_dependency 'rubyzip'

end
