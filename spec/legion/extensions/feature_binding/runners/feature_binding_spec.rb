# frozen_string_literal: true

require 'legion/extensions/feature_binding/runners/feature_binding'

RSpec.describe Legion::Extensions::FeatureBinding::Runners::FeatureBinding do
  let(:field) { Legion::Extensions::FeatureBinding::Helpers::BindingField.new }
  let(:host) do
    obj = Object.new
    obj.extend(described_class)
    obj.instance_variable_set(:@field, field)
    obj
  end

  describe '#register_feature' do
    it 'registers successfully' do
      result = host.register_feature(id: 'f:red', dimension: :color, value: :red)
      expect(result[:success]).to be true
      expect(result[:feature][:id]).to eq('f:red')
    end

    it 'returns failure at limit' do
      Legion::Extensions::FeatureBinding::Helpers::Constants::MAX_FEATURES.times do |i|
        host.register_feature(id: "f:#{i}", dimension: :color, value: i)
      end
      result = host.register_feature(id: 'f:overflow', dimension: :color, value: :x)
      expect(result[:success]).to be false
    end
  end

  describe '#bind_features' do
    before do
      host.register_feature(id: 'f:red', dimension: :color, value: :red)
      host.register_feature(id: 'f:circle', dimension: :shape, value: :circle)
    end

    it 'binds features into an object' do
      result = host.bind_features(feature_ids: %w[f:red f:circle])
      expect(result[:success]).to be true
      expect(result[:object][:features]).to eq(%w[f:red f:circle])
    end

    it 'fails with insufficient features' do
      result = host.bind_features(feature_ids: %w[f:red])
      expect(result[:success]).to be false
    end
  end

  describe '#attend_object' do
    it 'strengthens and confirms' do
      host.register_feature(id: 'a', dimension: :color, value: :x)
      host.register_feature(id: 'b', dimension: :shape, value: :y)
      bind_result = host.bind_features(feature_ids: %w[a b])
      obj_id = bind_result[:object][:id]
      result = host.attend_object(object_id: obj_id)
      expect(result[:success]).to be true
      expect(result[:object][:confirmed]).to be true
    end

    it 'returns failure for unknown object' do
      result = host.attend_object(object_id: :nope)
      expect(result[:success]).to be false
    end
  end

  describe '#unbind_object' do
    it 'removes the object' do
      host.register_feature(id: 'a', dimension: :color, value: :x)
      host.register_feature(id: 'b', dimension: :shape, value: :y)
      bind_result = host.bind_features(feature_ids: %w[a b])
      obj_id = bind_result[:object][:id]
      result = host.unbind_object(object_id: obj_id)
      expect(result[:success]).to be true
    end
  end

  describe '#illusory_conjunctions' do
    it 'returns illusory bindings' do
      result = host.illusory_conjunctions
      expect(result[:success]).to be true
      expect(result[:illusory]).to be_an(Array)
    end
  end

  describe '#search_features' do
    it 'searches by dimension' do
      host.register_feature(id: 'f:red', dimension: :color, value: :red)
      result = host.search_features(dimension: :color)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#update_feature_binding' do
    it 'decays and returns counts' do
      result = host.update_feature_binding
      expect(result[:success]).to be true
    end
  end

  describe '#feature_binding_stats' do
    it 'returns stats hash' do
      result = host.feature_binding_stats
      expect(result[:success]).to be true
      expect(result[:stats]).to include(:features, :objects)
    end
  end
end
