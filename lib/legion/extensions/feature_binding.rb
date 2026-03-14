# frozen_string_literal: true

require 'legion/extensions/feature_binding/version'
require 'legion/extensions/feature_binding/helpers/constants'
require 'legion/extensions/feature_binding/helpers/feature'
require 'legion/extensions/feature_binding/helpers/bound_object'
require 'legion/extensions/feature_binding/helpers/binding_field'
require 'legion/extensions/feature_binding/runners/feature_binding'
require 'legion/extensions/feature_binding/client'

module Legion
  module Extensions
    module FeatureBinding
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
