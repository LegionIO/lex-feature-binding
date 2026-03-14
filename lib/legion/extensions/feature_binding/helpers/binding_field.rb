# frozen_string_literal: true

module Legion
  module Extensions
    module FeatureBinding
      module Helpers
        class BindingField
          include Constants

          attr_reader :features, :objects, :binding_history

          def initialize
            @features        = {}
            @objects         = {}
            @binding_history = []
            @object_counter  = 0
          end

          def register_feature(id:, dimension:, value:, source: :perception, salience: 0.5)
            return @features[id] if @features.key?(id)
            return nil if @features.size >= MAX_FEATURES

            @features[id] = Feature.new(id: id, dimension: dimension, value: value, source: source, salience: salience)
          end

          def bind(feature_ids:, attention: false)
            ids = Array(feature_ids).select { |fid| @features.key?(fid) }
            return nil if ids.size < 2
            return nil if @objects.size >= MAX_OBJECTS

            @object_counter += 1
            obj_id = :"object_#{@object_counter}"
            strength = attention ? DEFAULT_BINDING_STRENGTH + ATTENTION_BOOST : DEFAULT_BINDING_STRENGTH

            obj = BoundObject.new(id: obj_id, feature_ids: ids, binding_strength: strength)
            obj.confirm if attention
            @objects[obj_id] = obj

            record_binding(obj_id, ids, attention)
            obj
          end

          def attend(object_id:)
            obj = @objects[object_id]
            return nil unless obj

            obj.strengthen
            obj.confirm unless obj.confirmed?
            obj
          end

          def unbind(object_id:)
            obj = @objects.delete(object_id)
            !obj.nil?
          end

          def features_of(object_id:)
            obj = @objects[object_id]
            return [] unless obj

            obj.feature_ids.filter_map { |fid| @features[fid]&.to_h }
          end

          def objects_with_feature(feature_id:)
            @objects.values.select { |o| o.includes_feature?(feature_id) }.map(&:to_h)
          end

          def illusory_conjunctions
            @objects.values.select { |o| o.state == :illusory }.map(&:to_h)
          end

          def unbound_features
            bound_ids = @objects.values.flat_map(&:feature_ids).uniq
            @features.values.reject { |f| bound_ids.include?(f.id) }.map(&:to_h)
          end

          def search_by_dimension(dimension:, value: nil)
            matches = @features.values.select { |f| f.dimension == dimension }
            matches = matches.select { |f| f.value == value } if value
            matches.map(&:to_h)
          end

          def decay_all
            @features.each_value(&:decay)
            @features.reject! { |_, f| f.faded? }

            @objects.each_value(&:decay)
            @objects.reject! { |_, o| o.dissolved? }
          end

          def feature_count
            @features.size
          end

          def object_count
            @objects.size
          end

          def to_h
            {
              features:          @features.size,
              objects:           @objects.size,
              confirmed_objects: @objects.values.count(&:confirmed?),
              illusory_count:    @objects.values.count { |o| o.state == :illusory },
              unbound_features:  unbound_features.size,
              history_size:      @binding_history.size
            }
          end

          private

          def record_binding(obj_id, feature_ids, attended)
            @binding_history << { object_id: obj_id, features: feature_ids, attended: attended, at: Time.now.utc }
            @binding_history.shift while @binding_history.size > MAX_BINDING_HISTORY
          end
        end
      end
    end
  end
end
