# Changelog

## 2.0.0 — Unreleased

### Added

- Fireworks for SwiftUI and UIKit through `.fireworks(C3DFireworksOptions)`.
- Rising rockets with golden spark trails, a visible slowdown before detonation, and randomized launch trajectories.
- Multicolored explosions with continuous curved filaments, incandescent cores, subtle glow, air resistance, gravity, and gradual fading.
- Six optional fireworks settings: `count`, `colors`, `launchInterval`, `playbackSpeed`, `size`, and `position`.
- Rendering, trajectory, cleanup, and performance tests, including six simultaneous explosions.
- New animated previews and 60 fps videos for fireworks, confetti, and glitter.

### Improved

- Firework explosions use one GPU geometry batch each, shared mesh buffers, and one elapsed-time update per burst.
- Completed firework salvos and confetti/glitter emitter nodes are removed from the scene.
- README with SwiftUI and UIKit examples, fireworks configuration, and migration instructions.

### Migration

`C3DConfettiType` has a new `.fireworks` case. Applications with exhaustive switches over this enum must add a matching case. Existing confetti and glitter calls are unchanged. iOS 15 remains the minimum supported version.
