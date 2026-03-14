# frozen_string_literal: true

require 'legion/extensions/feature_binding/helpers/constants'
require 'legion/extensions/feature_binding/helpers/feature'
require 'legion/extensions/feature_binding/helpers/bound_object'
require 'legion/extensions/feature_binding/helpers/binding_field'

module Legion
  module Extensions
    module Helpers; end

    module Actors
      module Every; end
    end
  end

  module Logging
    def self.debug(*); end
    def self.info(*); end
    def self.warn(*); end
    def self.error(*); end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
  Kernel.srand config.seed
end
