# Changelog

## Unreleased

### Added

- `throwConfetti(type:from:)` on `UIC3DView` and `C3DView` starts confetti, glitter, or fireworks from a point of the view, in UIKit coordinates.
- `C3DConfetti.defaultConfetti(colors:)` returns the 8 default confetti shapes with your own palette, ready to mix with your own images.
- `C3DConfetti(image:color:size:)` gives one element its own size multiplier, on top of the size of the options.

## 2.0.2 — 2026-11-05

### Fixed

- `UIC3DView` sets its camera as `pointOfView` at initialization, so `projectPoint` and `unprojectPoint` return scene coordinates before the first frame is rendered.

## 2.0.1 — 2026-11-05

### Added

- `C3DConfettiOptions(colors:)` tints the 8 default confetti images with your own palette, keeping every other setting.

### Changed

- Remove the test target and test sources from the package.

## 2.0.0 — 2026-10-11

### Added

- Fireworks for SwiftUI and UIKit through `.fireworks(C3DFireworksOptions)`.
- Rising rockets with golden spark trails, a visible slowdown before detonation, and randomized launch trajectories.
- Multicolored explosions with continuous curved filaments, incandescent cores, subtle glow, air resistance, gravity, and gradual fading.
- Six optional fireworks settings: `count`, `colors`, `launchInterval`, `playbackSpeed`, `size`, and `position`.
- New animated previews and 60 fps videos for fireworks, confetti, and glitter.

### Improved

- Firework explosions use one GPU geometry batch each, shared mesh buffers, and one elapsed-time update per burst.
- Completed firework salvos and confetti/glitter emitter nodes are removed from the scene.
- README with SwiftUI and UIKit examples, fireworks configuration, and refreshed demos.
