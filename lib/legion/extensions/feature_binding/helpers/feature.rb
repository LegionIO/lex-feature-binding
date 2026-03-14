# frozen_string_literal: true

module Legion
  module Extensions
    module FeatureBinding
      module Helpers
        class Feature
          include Constants

          attr_reader :id, :dimension, :value, :source, :detected_at
          attr_accessor :salience

          def initialize(id:, dimension:, value:, source: :perception, salience: 0.5)
            @id          = id
            @dimension   = dimension
            @value       = value
            @source      = source
            @salience    = salience.to_f.clamp(0.0, 1.0)
            @detected_at = Time.now.utc
          end

          def salient?
            @salience > FEATURE_SALIENCE_FLOOR
          end

          def decay
            @salience = [@salience - BINDING_DECAY, 0.0].max
          end

          def faded?
            @salience <= FEATURE_SALIENCE_FLOOR
          end

          def to_h
            {
              id:          @id,
              dimension:   @dimension,
              value:       @value,
              source:      @source,
              salience:    @salience.round(4),
              detected_at: @detected_at
            }
          end
        end
      end
    end
  end
end
