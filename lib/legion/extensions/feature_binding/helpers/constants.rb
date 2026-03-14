# frozen_string_literal: true

module Legion
  module Extensions
    module FeatureBinding
      module Helpers
        module Constants
          MAX_FEATURES = 200
          MAX_BINDINGS = 100
          MAX_OBJECTS = 50
          MAX_BINDING_HISTORY = 200

          BINDING_STRENGTH_FLOOR = 0.05
          BINDING_DECAY = 0.01
          BINDING_ALPHA = 0.15
          ATTENTION_BOOST = 0.3
          DEFAULT_BINDING_STRENGTH = 0.3

          ILLUSORY_CONJUNCTION_THRESHOLD = 0.3
          BINDING_CONFIRMATION_THRESHOLD = 0.6
          FEATURE_SALIENCE_FLOOR = 0.05

          FEATURE_DIMENSIONS = %i[
            shape color size motion texture location
            pitch volume timbre temporal_pattern
            semantic syntactic pragmatic
            valence arousal familiarity
          ].freeze

          BINDING_STATE_LABELS = {
            bound:     'features unified into coherent object',
            tentative: 'binding forming, not yet confirmed',
            illusory:  'incorrect binding (conjunction error)',
            unbound:   'features floating in pre-attentive field'
          }.freeze

          STRENGTH_LABELS = {
            (0.8..)     => :solid,
            (0.6...0.8) => :firm,
            (0.4...0.6) => :forming,
            (0.2...0.4) => :weak,
            (..0.2)     => :dissolving
          }.freeze
        end
      end
    end
  end
end
