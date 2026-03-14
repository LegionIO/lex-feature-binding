# frozen_string_literal: true

RSpec.describe Legion::Extensions::FeatureBinding::Helpers::BoundObject do
  subject(:obj) { described_class.new(id: :obj_one, feature_ids: %w[f:red f:circle]) }

  let(:constants) { Legion::Extensions::FeatureBinding::Helpers::Constants }

  describe '#initialize' do
    it 'sets id and feature_ids' do
      expect(obj.id).to eq(:obj_one)
      expect(obj.feature_ids).to eq(%w[f:red f:circle])
    end

    it 'deduplicates feature_ids' do
      o = described_class.new(id: :dup, feature_ids: %w[a a b])
      expect(o.feature_ids).to eq(%w[a b])
    end

    it 'uses default binding strength' do
      expect(obj.binding_strength).to eq(constants::DEFAULT_BINDING_STRENGTH)
    end

    it 'starts unconfirmed' do
      expect(obj.confirmed?).to be false
    end
  end

  describe '#confirm' do
    it 'marks as confirmed' do
      obj.confirm
      expect(obj.confirmed?).to be true
    end

    it 'boosts binding strength' do
      before = obj.binding_strength
      obj.confirm
      expect(obj.binding_strength).to be > before
    end

    it 'sets confirmed_at' do
      obj.confirm
      expect(obj.confirmed_at).to be_a(Time)
    end
  end

  describe '#strengthen' do
    it 'increases binding strength' do
      before = obj.binding_strength
      obj.strengthen
      expect(obj.binding_strength).to be > before
    end

    it 'clamps at 1.0' do
      10.times { obj.strengthen }
      expect(obj.binding_strength).to be <= 1.0
    end

    it 'accepts custom amount' do
      before = obj.binding_strength
      obj.strengthen(0.01)
      expect(obj.binding_strength).to eq(before + 0.01)
    end
  end

  describe '#decay' do
    it 'reduces binding strength' do
      before = obj.binding_strength
      obj.decay
      expect(obj.binding_strength).to be < before
    end

    it 'does not go below zero' do
      100.times { obj.decay }
      expect(obj.binding_strength).to be >= 0.0
    end
  end

  describe '#dissolved?' do
    it 'returns false initially' do
      expect(obj.dissolved?).to be false
    end

    it 'returns true at floor' do
      obj.binding_strength = constants::BINDING_STRENGTH_FLOOR
      expect(obj.dissolved?).to be true
    end
  end

  describe '#state' do
    it 'returns :tentative initially (unconfirmed, above illusory threshold)' do
      expect(obj.state).to eq(:tentative)
    end

    it 'returns :bound when confirmed and above confirmation threshold' do
      obj.binding_strength = constants::BINDING_CONFIRMATION_THRESHOLD + 0.1
      obj.confirm
      expect(obj.state).to eq(:bound)
    end

    it 'returns :illusory below illusory threshold but above floor' do
      obj.binding_strength = constants::ILLUSORY_CONJUNCTION_THRESHOLD - 0.1
      expect(obj.state).to eq(:illusory)
    end

    it 'returns :unbound at floor' do
      obj.binding_strength = constants::BINDING_STRENGTH_FLOOR
      expect(obj.state).to eq(:unbound)
    end
  end

  describe '#feature_count' do
    it 'returns number of features' do
      expect(obj.feature_count).to eq(2)
    end
  end

  describe '#includes_feature?' do
    it 'returns true for included feature' do
      expect(obj.includes_feature?('f:red')).to be true
    end

    it 'returns false for missing feature' do
      expect(obj.includes_feature?('f:blue')).to be false
    end
  end

  describe '#strength_label' do
    it 'returns a symbol' do
      expect(obj.strength_label).to be_a(Symbol)
    end

    it 'returns :weak for default strength (0.3)' do
      expect(obj.strength_label).to eq(:weak)
    end

    it 'returns :solid for high strength' do
      obj.binding_strength = 0.9
      expect(obj.strength_label).to eq(:solid)
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      h = obj.to_h
      expect(h).to include(:id, :features, :feature_count, :binding_strength,
                           :strength_label, :state, :state_label, :confirmed, :bound_at)
    end
  end
end
