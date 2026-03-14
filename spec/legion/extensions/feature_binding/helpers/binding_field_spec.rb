# frozen_string_literal: true

RSpec.describe Legion::Extensions::FeatureBinding::Helpers::BindingField do
  subject(:field) { described_class.new }

  let(:constants) { Legion::Extensions::FeatureBinding::Helpers::Constants }

  def register_pair
    field.register_feature(id: 'f:red', dimension: :color, value: :red)
    field.register_feature(id: 'f:circle', dimension: :shape, value: :circle)
  end

  describe '#register_feature' do
    it 'adds a feature' do
      f = field.register_feature(id: 'f:red', dimension: :color, value: :red)
      expect(f).to be_a(Legion::Extensions::FeatureBinding::Helpers::Feature)
      expect(field.feature_count).to eq(1)
    end

    it 'returns existing feature on duplicate id' do
      first = field.register_feature(id: 'f:red', dimension: :color, value: :red)
      second = field.register_feature(id: 'f:red', dimension: :color, value: :blue)
      expect(second).to equal(first)
      expect(field.feature_count).to eq(1)
    end

    it 'enforces MAX_FEATURES limit' do
      constants::MAX_FEATURES.times do |i|
        field.register_feature(id: "f:#{i}", dimension: :color, value: i)
      end
      result = field.register_feature(id: 'f:overflow', dimension: :color, value: :x)
      expect(result).to be_nil
    end
  end

  describe '#bind' do
    it 'creates a bound object from feature ids' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle])
      expect(obj).to be_a(Legion::Extensions::FeatureBinding::Helpers::BoundObject)
      expect(field.object_count).to eq(1)
    end

    it 'returns nil with fewer than 2 valid features' do
      field.register_feature(id: 'f:red', dimension: :color, value: :red)
      expect(field.bind(feature_ids: %w[f:red])).to be_nil
    end

    it 'ignores unknown feature ids' do
      field.register_feature(id: 'f:red', dimension: :color, value: :red)
      expect(field.bind(feature_ids: %w[f:red f:nonexistent])).to be_nil
    end

    it 'boosts strength with attention' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle], attention: true)
      expect(obj.binding_strength).to be > constants::DEFAULT_BINDING_STRENGTH
    end

    it 'auto-confirms with attention' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle], attention: true)
      expect(obj.confirmed?).to be true
    end

    it 'records binding in history' do
      register_pair
      field.bind(feature_ids: %w[f:red f:circle])
      expect(field.binding_history.size).to eq(1)
    end

    it 'enforces MAX_OBJECTS limit' do
      (constants::MAX_OBJECTS + 5).times do |i|
        field.register_feature(id: "a:#{i}", dimension: :color, value: i)
        field.register_feature(id: "b:#{i}", dimension: :shape, value: i)
        field.bind(feature_ids: ["a:#{i}", "b:#{i}"])
      end
      expect(field.object_count).to be <= constants::MAX_OBJECTS
    end
  end

  describe '#attend' do
    it 'strengthens and confirms an object' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle])
      result = field.attend(object_id: obj.id)
      expect(result.confirmed?).to be true
      expect(result.binding_strength).to be > constants::DEFAULT_BINDING_STRENGTH
    end

    it 'returns nil for unknown object' do
      expect(field.attend(object_id: :nonexistent)).to be_nil
    end
  end

  describe '#unbind' do
    it 'removes an object' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle])
      expect(field.unbind(object_id: obj.id)).to be true
      expect(field.object_count).to eq(0)
    end

    it 'returns false for unknown object' do
      expect(field.unbind(object_id: :nonexistent)).to be false
    end
  end

  describe '#features_of' do
    it 'returns features of a bound object' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle])
      features = field.features_of(object_id: obj.id)
      expect(features.size).to eq(2)
      expect(features.first).to include(:id, :dimension)
    end

    it 'returns empty for unknown object' do
      expect(field.features_of(object_id: :nope)).to be_empty
    end
  end

  describe '#objects_with_feature' do
    it 'finds objects containing a feature' do
      register_pair
      field.bind(feature_ids: %w[f:red f:circle])
      results = field.objects_with_feature(feature_id: 'f:red')
      expect(results.size).to eq(1)
    end

    it 'returns empty when no objects contain feature' do
      expect(field.objects_with_feature(feature_id: 'f:none')).to be_empty
    end
  end

  describe '#illusory_conjunctions' do
    it 'returns objects in illusory state' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle])
      obj.binding_strength = constants::ILLUSORY_CONJUNCTION_THRESHOLD - 0.1
      illusions = field.illusory_conjunctions
      expect(illusions.size).to eq(1)
    end
  end

  describe '#unbound_features' do
    it 'returns features not bound to any object' do
      register_pair
      field.register_feature(id: 'f:large', dimension: :size, value: :large)
      field.bind(feature_ids: %w[f:red f:circle])
      unbound = field.unbound_features
      expect(unbound.size).to eq(1)
      expect(unbound.first[:id]).to eq('f:large')
    end
  end

  describe '#search_by_dimension' do
    it 'filters by dimension' do
      field.register_feature(id: 'f:red', dimension: :color, value: :red)
      field.register_feature(id: 'f:blue', dimension: :color, value: :blue)
      field.register_feature(id: 'f:circle', dimension: :shape, value: :circle)
      results = field.search_by_dimension(dimension: :color)
      expect(results.size).to eq(2)
    end

    it 'filters by dimension and value' do
      field.register_feature(id: 'f:red', dimension: :color, value: :red)
      field.register_feature(id: 'f:blue', dimension: :color, value: :blue)
      results = field.search_by_dimension(dimension: :color, value: :red)
      expect(results.size).to eq(1)
    end
  end

  describe '#decay_all' do
    it 'decays features and objects' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle])
      before_feature = field.features['f:red'].salience
      before_obj = obj.binding_strength
      field.decay_all
      expect(field.features['f:red']&.salience || 0).to be <= before_feature
      expect(obj.binding_strength).to be < before_obj
    end

    it 'removes faded features' do
      field.register_feature(id: 'f:faint', dimension: :color, value: :x, salience: 0.06)
      10.times { field.decay_all }
      expect(field.features).not_to have_key('f:faint')
    end

    it 'removes dissolved objects' do
      register_pair
      obj = field.bind(feature_ids: %w[f:red f:circle])
      obj.binding_strength = constants::BINDING_STRENGTH_FLOOR + constants::BINDING_DECAY
      field.decay_all
      expect(field.object_count).to eq(0)
    end
  end

  describe '#to_h' do
    it 'returns summary hash' do
      h = field.to_h
      expect(h).to include(:features, :objects, :confirmed_objects, :illusory_count,
                           :unbound_features, :history_size)
    end
  end
end
