# frozen_string_literal: true

require_relative 'lib/legion/extensions/feature_binding/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-feature-binding'
  spec.version       = Legion::Extensions::FeatureBinding::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']
  spec.summary       = 'LegionIO feature binding extension'
  spec.description   = "Treisman's Feature Integration Theory for LegionIO — " \
                       'attention as glue binding features into unified percepts'
  spec.homepage      = 'https://github.com/LegionIO/lex-feature-binding'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/master/README.md"
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']   = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']
end
