# 🎉 Confetti3D

Confetti, glitter, and fireworks for iOS apps built with **SwiftUI** or **UIKit**.
A lightweight Swift package powered by SceneKit, with customizable effects and no external dependencies.

- 🎆 Fireworks with rising rockets, golden sparks, curved luminous trails, and fading explosions.
- 🎨 Confetti with custom images, colors, and emission settings.
- ✨ Glitter in warm metallic tones.
- 📱 Confetti and glitter can react to the device's accelerometer.
- ⚡ Firework explosions animate on the GPU with shared geometry and one draw batch per explosion.

<p align="center">
  <img src="https://raw.githubusercontent.com/maxime-day/confetti3Dgifs/main/fireworks.gif" width="360" alt="One firework salvo followed by two simultaneous salvos, with colorful curved trails" />
</p>

<p align="center">
  <a href="https://github.com/maxime-day/confetti3Dgifs/raw/refs/heads/main/fireworks.mp4">Download the high-quality 60 fps fireworks video</a>
</p>

| Confetti | Glitter |
| --- | --- |
| <img src="https://raw.githubusercontent.com/maxime-day/confetti3Dgifs/main/confetti.gif" width="300" alt="Colorful 3D confetti" /> | <img src="https://raw.githubusercontent.com/maxime-day/confetti3Dgifs/main/glitter.gif" width="300" alt="Warm metallic glitter" /> |
| [Download 60 fps video](https://github.com/maxime-day/confetti3Dgifs/raw/refs/heads/main/confetti.mp4) | [Download 60 fps video](https://github.com/maxime-day/confetti3Dgifs/raw/refs/heads/main/glitter.mp4) |

GIFs provide lightweight animated previews. The linked videos preserve the full frame rate and finer color gradients.

## Installation

Requires **iOS 15+** and **Swift 5.7+**.

In Xcode, add `https://github.com/maxime-day/Confetti3D.git` as a package dependency, or add it to `Package.swift`:

```swift
.package(url: "https://github.com/maxime-day/Confetti3D.git", from: "2.0.0")
```

## SwiftUI

Keep a `C3DView` in your view and call `throwConfetti` when you want to celebrate:

```swift
import Confetti3D
import SwiftUI

struct CelebrationView: View {
    @State private var effects = C3DView()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Button("Celebrate") {
                effects.throwConfetti(type: .fireworks(.defaultOptions))
            }
            .buttonStyle(.borderedProminent)

            effects
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}
```

Choose an effect:

```swift
effects.throwConfetti() // Default: confetti.
effects.throwConfetti(type: .glitter(.defaultOptions))
effects.throwConfetti(type: .fireworks(.defaultOptions))
```

## UIKit

Add a `UIC3DView` as an overlay, then trigger effects with the same API:

```swift
import Confetti3D
import UIKit

final class CelebrationViewController: UIViewController {
    private let effects = UIC3DView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        effects.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(effects)
        NSLayoutConstraint.activate([
            effects.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            effects.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            effects.topAnchor.constraint(equalTo: view.topAnchor),
            effects.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func celebrate() {
        effects.throwConfetti(type: .fireworks(.defaultOptions))
    }
}
```

## Fireworks

Each rocket rises along a slightly randomized path, slows before detonation, and explodes into a colorful spherical burst. Embers leave continuous curved filaments, slow under air resistance, gently fall, and fade. White-hot cores and a subtle colored glow are drawn inside the same geometry.

The defaults provide a complete three-rocket salvo. Only six settings are exposed:

| Setting | Default | Purpose |
| --- | --- | --- |
| `count` | `3` | Number of rockets in one salvo. |
| `colors` | Cyan, ember red, warm gold, green, purple | Rockets cycle through the palette. An empty palette uses the defaults. |
| `launchInterval` | `0.45` seconds | Delay on the animation timeline (about `0.64` real seconds by default). Use `0` for simultaneous launches. |
| `playbackSpeed` | `1` | Speed of the entire effect. `1` is normal speed; `0.5` is half speed. |
| `size` | `1` | Size multiplier for luminous heads and trails. |
| `position` | `(0, -1.2, 0)` | Center of the launch area in SceneKit scene units. |

```swift
import SceneKit

let options = C3DFireworksOptions(
    count: 3,
    colors: [.systemCyan, .systemPurple],
    launchInterval: 0.3
)
effects.throwConfetti(type: .fireworks(options))
```

All settings are optional. At the default speed, the ascent lasts about 2.5 seconds; `playbackSpeed` scales the ascent, launch intervals, explosion, and fading together. Fireworks use their own gravity, independent of device motion. A dark background shows the glow best.

The physics, spark lifetime, and 140 embers per explosion are tuned internally. Explosions use shared immutable mesh buffers and GPU shader modifiers; the CPU updates one elapsed-time value per burst. Connected ribbons create smooth trails without additional particle emitters or a full-screen bloom pass. Finished salvos remove their nodes automatically.

## Custom confetti and glitter

Use your own images and colors with `C3DConfettiOptions`:

```swift
import UIKit

let particles = [
    C3DConfetti(image: UIImage(named: "confetti")!, color: .systemPink),
    C3DConfetti(image: UIImage(named: "star")!, color: .systemCyan)
]

effects.throwConfetti(type: .confetti(C3DConfettiOptions(
    confetti: particles,
    isAffectedByGravity: true,
    birthRate: 40,
    emissionDuration: 1,
    lifeSpan: 10,
    size: 1,
    position: SCNVector3(0, 0, 0),
    emittingDirection: SCNVector3(0, 1, 0)
)))
```

`C3DGlitterOptions` accepts the same settings. `isAffectedByGravity` enables device-motion updates; both effects also have their own built-in downward acceleration. Images are multiplied by their tint color: use white shapes on a transparent background when you want the specified colors to show accurately.

See [CHANGELOG.md](CHANGELOG.md) for the release notes.
