# lex-feature-binding

Feature binding modeling for the LegionIO brain-modeled cognitive architecture.

## What It Does

Implements the cognitive binding problem — how separate features from different processing streams are combined into unified object percepts. Registers unbound feature sets across visual, auditory, semantic, spatial, temporal, and affective dimensions, then binds them into coherent bound objects. Detects binding conflicts when feature dimensions contradict each other, and manages a vividness-based object store with decay.

Based on Treisman's Feature Integration Theory.

## Usage

```ruby
client = Legion::Extensions::FeatureBinding::Client.new

# Register incoming features from multiple sensory streams
client.register_features(
  features: {
    semantic: 'incoming HTTP request',
    temporal: :recent,
    affective: :neutral,
    spatial: :network_boundary
  }
)
# => { success: true, feature_set_id: "...", dimensions_present: [:semantic, :temporal, :affective, :spatial],
#      ready_to_bind: true }

# Bind into a unified object percept
client.bind_features(feature_set_id: '...', binding_mode: :automatic)
# => { success: true, object_id: "...", coherence: 0.75, bound: true, conflicts: [] }

# Check for feature conflicts before binding
client.detect_conflicts(feature_set_id: '...')
# => { conflicts: [], conflict_count: 0, severity: :none }

# Attend to an object to boost its coherence
client.attend_to_object(object_id: '...')
# => { coherence_boost: 0.2, new_coherence: 0.95 }

# View current bound objects
client.bound_objects
# => { objects: [...sorted by vividness], count: 5 }

# Overall binding quality
client.binding_quality
# => { avg_coherence: 0.72, coherence_label: :coherent, conflict_rate: 0.05 }

# Periodic tick: decay vividness, archive faded objects
client.update_feature_binding
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
