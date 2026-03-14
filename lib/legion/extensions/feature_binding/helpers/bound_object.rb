# frozen_string_literal: true

module Legion
  module Extensions
    module FeatureBinding
      module Helpers
        class BoundObject
          include Constants

          attr_reader :id, :feature_ids, :bound_at, :confirmed_at
          attr_accessor :binding_strength

          def initialize(id:, feature_ids:, binding_strength: DEFAULT_BINDING_STRENGTH)
            @id               = id
            @feature_ids      = Array(feature_ids).uniq
            @binding_strength = binding_strength.to_f.clamp(0.0, 1.0)
            @bound_at         = Time.now.utc
            @confirmed_at     = nil
          end

          def confirm
            @confirmed_at = Time.now.utc
            @binding_strength = [@binding_strength + ATTENTION_BOOST, 1.0].min
          end

          def confirmed?
            !@confirmed_at.nil?
          end

          def strengthen(amount = ATTENTION_BOOST)
            @binding_strength = [@binding_strength + amount, 1.0].min
          end

          def decay
            @binding_strength = [@binding_strength - BINDING_DECAY, 0.0].max
          end

          def dissolved?
            @binding_strength <= BINDING_STRENGTH_FLOOR
          end

          def state
            if @binding_strength >= BINDING_CONFIRMATION_THRESHOLD && confirmed?
              :bound
            elsif @binding_strength >= ILLUSORY_CONJUNCTION_THRESHOLD
              :tentative
            elsif @binding_strength > BINDING_STRENGTH_FLOOR
              :illusory
            else
              :unbound
            end
          end

          def feature_count
            @feature_ids.size
          end

          def includes_feature?(feature_id)
            @feature_ids.include?(feature_id)
          end

          def strength_label
            STRENGTH_LABELS.each { |range, lbl| return lbl if range.cover?(@binding_strength) }
            :dissolving
          end

          def to_h
            {
              id:               @id,
              features:         @feature_ids.dup,
              feature_count:    feature_count,
              binding_strength: @binding_strength.round(4),
              strength_label:   strength_label,
              state:            state,
              state_label:      BINDING_STATE_LABELS[state],
              confirmed:        confirmed?,
              bound_at:         @bound_at,
              confirmed_at:     @confirmed_at
            }
          end
        end
      end
    end
  end
end
