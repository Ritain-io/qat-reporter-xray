#encoding: utf-8
# require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'qat', 'version.rb'))

Gem::Specification.new do |gem|
  gem.name        = 'qat-reporter-xray'
  gem.version     = '9.0.0'
  gem.summary     = %q{Utility for Test Reports in Jira Xray.}
  gem.description = <<-DESC
  QAT Reporter Xray bellong to the QAT-Reporter collection of tools and is intended
  for importing test report information in Jira.
  DESC
  gem.email    = 'qatoolkit@readinessit.com'
  gem.homepage = 'https://www.ritain.io'
  gem.metadata    = {
      'source_code_uri'   => 'https://github.com/Ritain-io/qat-reporter-xray'
  }
  gem.authors = ['QAT']
  gem.license = 'GPL-3.0'

  extra_files = %w[LICENSE]
  gem.files   = Dir.glob('{lib}/**/*') + extra_files

  gem.required_ruby_version = '~> 3.2'

  # Development dependencies
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'aruba'
  gem.add_development_dependency 'qat-devel', '~> 9.0.0'
  gem.add_development_dependency 'qat-cucumber', '~> 9.0.0'

  # GEM dependencies
  gem.add_dependency 'qat-logger' , '~> 9.0.0'
  gem.add_dependency 'rest-client'
  gem.add_dependency 'rubyzip'

end
