# lex-feature-binding

**Level 3 Documentation** — Parent: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Feature binding modeling for the LegionIO cognitive architecture. Implements the cognitive binding problem — how the brain combines separate features (color, shape, motion, sound) from different processing streams into unified object percepts. Binds feature sets into coherent object representations, detects binding conflicts (when features don't cohere), and manages a perceptual object store with decay. Relevant to how the agent integrates multimodal sensory input.

Based on Treisman's Feature Integration Theory.

## Gem Info

- **Gem name**: `lex-feature-binding`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::FeatureBinding`
- **Location**: `extensions-agentic/lex-feature-binding/`

## File Structure

```
lib/legion/extensions/feature_binding/
  feature_binding.rb            # Top-level requires
  version.rb                    # VERSION = '0.1.0`
  client.rb                     # Client class
  helpers/
    constants.rb                # FEATURE_DIMENSIONS, BINDING_MODES, COHERENCE_LABELS, thresholds
    feature_set.rb              # FeatureSet value object (unbound features)
    bound_object.rb             # BoundObject value object (unified percept)
    binding_engine.rb           # Engine: binding, conflict detection, object store
  runners/
    feature_binding.rb          # Runner module: all public methods
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `FEATURE_DIMENSIONS` | `[:visual, :auditory, :semantic, :spatial, :temporal, :affective]` | Bindable feature types |
| `BINDING_THRESHOLD` | 0.5 | Minimum coherence score for successful binding |
| `CONFLICT_THRESHOLD` | 0.4 | Feature divergence above which binding conflict is flagged |
| `OBJECT_DECAY_RATE` | 0.03 | Object vividness lost per cycle |
| `ATTENTION_BOOST` | 0.2 | Binding coherence boost when object is attended |
| `MAX_OBJECTS` | 100 | Active bound object store cap |
| `MAX_OBJECT_HISTORY` | 300 | Archived object cap |
| `MAX_FEATURE_SETS` | 200 | Unbound feature queue cap |
| `COHERENCE_LABELS` | range hash | `tightly_bound / coherent / loosely_bound / incoherent` |
| `BINDING_MODES` | `[:automatic, :attention_gated, :effortful]` | How binding was achieved |

## Runners

All methods in `Legion::Extensions::FeatureBinding::Runners::FeatureBinding`.

| Method | Key Args | Returns |
|---|---|---|
| `register_features` | `features: {}, context: {}` | `{ success:, feature_set_id:, dimensions_present:, ready_to_bind: }` |
| `bind_features` | `feature_set_id:, binding_mode: :automatic` | `{ success:, object_id:, coherence:, bound:, conflicts: }` |
| `attend_to_object` | `object_id:` | `{ success:, object_id:, coherence_boost:, new_coherence: }` |
| `detect_conflicts` | `feature_set_id:` | `{ success:, conflicts:, conflict_count:, severity: }` |
| `bound_objects` | — | `{ success:, objects:, count: }` (sorted by vividness) |
| `search_objects` | `dimension:, value: nil` | `{ success:, matches:, count: }` |
| `unbind_object` | `object_id:` | `{ success:, object_id:, unbound:, features_released: }` |
| `binding_quality` | — | `{ success:, avg_coherence:, coherence_label:, conflict_rate: }` |
| `update_feature_binding` | — | `{ success:, faded_count:, archived_count: }` |
| `feature_binding_stats` | — | Full stats hash |

## Helpers

### `FeatureSet`
Unbound feature collection. Attributes: `id`, `features` (hash by dimension), `context`, `dimensions_present` (array), `created_at`. `to_h`.

### `BoundObject`
Unified percept. Attributes: `id`, `features` (hash by dimension), `coherence`, `vividness`, `binding_mode`, `conflicts` (array), `created_at`, `last_attended_at`. Key methods: `attend!` (boost coherence), `decay!`, `faded?`, `coherence_label`, `to_h`.

### `BindingEngine`
Central store: `@feature_sets` (hash by id), `@objects` (hash by id), `@history` (array). Key methods:
- `register(features:, context:)`: creates FeatureSet, checks if >= 2 dimensions present for binding readiness
- `bind(feature_set_id:, binding_mode:)`: retrieves FeatureSet, calls `detect_conflicts_for`, computes coherence from dimension coverage and conflict absence, creates BoundObject if >= threshold
- `detect_conflicts_for(feature_set)`: checks dimension pairs for value contradictions (temporal vs spatial mismatches, affective vs visual mismatches)
- `attend(object_id:)`: calls `object.attend!`, adds `ATTENTION_BOOST` to coherence
- `decay_all`: calls `decay!` on all objects, archives those below vividness floor

## Integration Points

- `bind_features` called from lex-tick's `sensory_processing` phase to unify multimodal sensor inputs
- Bound objects feed lex-episodic-buffer's `bind_episode` as pre-processed unified percepts
- `binding_quality[:conflict_rate]` feeds lex-dissonance as a perceptual inconsistency signal
- `attend_to_object` called when lex-tick's `emotional_evaluation` phase boosts salience of a percept
- `update_feature_binding` maps to lex-tick's periodic maintenance cycle

## Development Notes

- Coherence is computed from: dimension coverage (more dimensions = higher coherence) minus conflict penalty
- Conflict detection is cross-dimension: temporal conflicts with spatial, affective conflicts with visual
- Binding fails (not persisted as BoundObject) when coherence < `BINDING_THRESHOLD` — FeatureSet remains queued
- `:attention_gated` binding mode has higher effective threshold (requires explicit `attend_to_object` before binding)
- `:effortful` binding mode can overcome conflicts at cost of lower final coherence score
