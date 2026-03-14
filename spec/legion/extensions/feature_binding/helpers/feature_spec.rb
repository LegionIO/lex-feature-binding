# frozen_string_literal: true

RSpec.describe Legion::Extensions::FeatureBinding::Helpers::Feature do
  subject(:feature) { described_class.new(id: 'f:red', dimension: :color, value: :red) }

  let(:constants) { Legion::Extensions::FeatureBinding::Helpers::Constants }

  describe '#initialize' do
    it 'sets id, dimension, and value' do
      expect(feature.id).to eq('f:red')
      expect(feature.dimension).to eq(:color)
      expect(feature.value).to eq(:red)
    end

    it 'defaults source to :perception' do
      expect(feature.source).to eq(:perception)
    end

    it 'defaults salience to 0.5' do
      expect(feature.salience).to eq(0.5)
    end

    it 'records detected_at' do
      expect(feature.detected_at).to be_a(Time)
    end

    it 'clamps salience to [0, 1]' do
      high = described_class.new(id: 'h', dimension: :color, value: :x, salience: 5.0)
      low  = described_class.new(id: 'l', dimension: :color, value: :x, salience: -1.0)
      expect(high.salience).to eq(1.0)
      expect(low.salience).to eq(0.0)
    end

    it 'accepts custom source' do
      f = described_class.new(id: 'x', dimension: :shape, value: :circle, source: :memory)
      expect(f.source).to eq(:memory)
    end
  end

  describe '#salient?' do
    it 'returns true when above floor' do
      expect(feature.salient?).to be true
    end

    it 'returns false at zero salience' do
      feature.salience = 0.0
      expect(feature.salient?).to be false
    end
  end

  describe '#decay' do
    it 'reduces salience' do
      before = feature.salience
      feature.decay
      expect(feature.salience).to be < before
    end

    it 'does not go below zero' do
      100.times { feature.decay }
      expect(feature.salience).to be >= 0.0
    end
  end

  describe '#faded?' do
    it 'returns false for a new feature' do
      expect(feature.faded?).to be false
    end

    it 'returns true when salience at floor' do
      feature.salience = constants::FEATURE_SALIENCE_FLOOR
      expect(feature.faded?).to be true
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      h = feature.to_h
      expect(h).to include(:id, :dimension, :value, :source, :salience, :detected_at)
    end

    it 'rounds salience' do
      feature.salience = 0.12345
      expect(feature.to_h[:salience]).to eq(0.1235)
    end
  end
end
