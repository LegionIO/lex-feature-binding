# frozen_string_literal: true

require 'legion/extensions/feature_binding/client'

RSpec.describe Legion::Extensions::FeatureBinding::Client do
  subject(:client) { described_class.new }

  it 'registers and binds features' do
    client.register_feature(id: 'f:red', dimension: :color, value: :red)
    client.register_feature(id: 'f:circle', dimension: :shape, value: :circle)
    result = client.bind_features(feature_ids: %w[f:red f:circle], attention: true)
    expect(result[:success]).to be true
    expect(result[:object][:confirmed]).to be true
  end

  it 'reports stats' do
    result = client.feature_binding_stats
    expect(result[:success]).to be true
  end
end
