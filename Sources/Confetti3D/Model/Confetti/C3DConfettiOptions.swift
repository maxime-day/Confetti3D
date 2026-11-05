//
//  C3DConfettiOptions.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

import UIKit
import SceneKit

/// Configuration options for the confetti particle system.
public struct C3DConfettiOptions: Sendable {
    /// The list of confetti elements to emit.
    let confetti: [C3DConfetti]
    
    /// Indicates whether the confetti is affected by gravity.
    let isAffectedByGravity: Bool
    
    /// The number of particles emitted per second.
    let birthRate: Int
    
    /// The duration (in seconds) during which particles are emitted.
    let emissionDuration: TimeInterval
    
    /// The total lifespan (in seconds) of each particle.
    let lifeSpan: TimeInterval
    
    /// The base size multiplier applied to each confetti image.
    let size: CGFloat

    /// The position of the emitter
    let position: SCNVector3

    /// The direction of the emitter
    let emittingDirection: SCNVector3

    /// The initial speed of the particles.
    let velocity: CGFloat

    /// The random variation of the initial speed, in both directions.
    let velocityVariation: CGFloat

    /// The opening angle of the emission cone, in degrees.
    let spreadingAngle: CGFloat

    /// How fast the particles slow down in the air.
    let damping: CGFloat

    /// Initializes a new set of options for the confetti emitter.
    ///
    /// - Parameters:
    ///   - confetti: An array of `C3DConfetti` elements to be used in the emitter.
    ///   - isAffectedByGravity: Whether particles should be influenced by gravity. Defaults to `true`.
    ///   - birthRate: The number of particles emitted per second. Defaults to `40`.
    ///   - emissionDuration: The duration during which the emitter releases particles. Defaults to `3` seconds.
    ///   - lifeSpan: The lifespan of each confetti particle. Defaults to `10` seconds.
    ///   - size: A scale factor applied to confetti images. Defaults to `1`.
    public init(confetti: [C3DConfetti],
                isAffectedByGravity: Bool = true,
                birthRate: Int = 70,
                emissionDuration: TimeInterval = 1,
                lifeSpan: TimeInterval = 10,
                size: CGFloat = 1,
                position: SCNVector3 = SCNVector3(0, 0, 0),
                emittingDirection: SCNVector3 = SCNVector3(0, 1, 0),
                velocity: CGFloat = 3,
                velocityVariation: CGFloat = 0,
                spreadingAngle: CGFloat = 40,
                damping: CGFloat = 1) {
        self.confetti = confetti
        self.isAffectedByGravity = isAffectedByGravity
        self.birthRate = birthRate
        self.emissionDuration = emissionDuration
        self.lifeSpan = lifeSpan
        self.size = size
        self.position = position
        self.emittingDirection = emittingDirection
        self.velocity = velocity
        self.velocityVariation = velocityVariation
        self.spreadingAngle = spreadingAngle
        self.damping = damping
    }

    /// Initializes options that tint the default confetti images with your own colors.
    ///
    /// Colors are paired with the 8 default images in order, and the images repeat when there are more colors.
    /// An empty array keeps the default colors.
    ///
    /// - Parameters:
    ///   - colors: The tint colors applied to the default confetti images.
    ///   - isAffectedByGravity: Whether particles should be influenced by gravity. Defaults to `true`.
    ///   - birthRate: The number of particles emitted per second. Defaults to `70`.
    ///   - emissionDuration: The duration during which the emitter releases particles. Defaults to `1` second.
    ///   - lifeSpan: The lifespan of each confetti particle. Defaults to `10` seconds.
    ///   - size: A scale factor applied to confetti images. Defaults to `1`.
    ///   - position: The position of the emitter. Defaults to the scene center.
    ///   - emittingDirection: The direction of the emitter. Defaults to up.
    public init(colors: [UIColor],
                isAffectedByGravity: Bool = true,
                birthRate: Int = 70,
                emissionDuration: TimeInterval = 1,
                lifeSpan: TimeInterval = 10,
                size: CGFloat = 1,
                position: SCNVector3 = SCNVector3(0, 0, 0),
                emittingDirection: SCNVector3 = SCNVector3(0, 1, 0)) {
        self.init(confetti: Constants.confetti(colors: colors),
                  isAffectedByGravity: isAffectedByGravity,
                  birthRate: birthRate,
                  emissionDuration: emissionDuration,
                  lifeSpan: lifeSpan,
                  size: size,
                  position: position,
                  emittingDirection: emittingDirection)
    }
}

extension C3DConfettiOptions {
    /// A predefined set of default confetti options using the default confetti assets.
    ///
    /// Includes 8 colorful confetti images with associated tint colors,
    /// default emission values, and gravity enabled.
    public static let defaultOptions = C3DConfettiOptions(confetti: Constants.defaultConfetti)

    /// The same options, emitting from another position.
    func with(position: SCNVector3) -> C3DConfettiOptions {
        C3DConfettiOptions(confetti: confetti,
                           isAffectedByGravity: isAffectedByGravity,
                           birthRate: birthRate,
                           emissionDuration: emissionDuration,
                           lifeSpan: lifeSpan,
                           size: size,
                           position: position,
                           emittingDirection: emittingDirection,
                           velocity: velocity,
                           velocityVariation: velocityVariation,
                           spreadingAngle: spreadingAngle,
                           damping: damping)
    }
}

extension C3DConfetti {
    /// The 8 default confetti shapes, tinted with your colors.
    ///
    /// Colors are paired with the images in order, and the images repeat when there are more colors.
    /// An empty array keeps the default colors. Combine the result with your own `C3DConfetti`,
    /// for example a picture with a `nil` color to keep its original colors.
    ///
    /// - Parameter colors: The tint colors applied to the default confetti images.
    public static func defaultConfetti(colors: [UIColor] = []) -> [C3DConfetti] {
        Constants.confetti(colors: colors)
    }
}

fileprivate enum Constants {
    /// The default confetti elements used in `C3DConfettiOptions.defaultOptions`.
    ///
    /// Each confetti is represented by a unique image located in the module bundle,
    /// and is paired with a specific color overlay to enhance visual diversity.
    static let defaultConfetti = confetti(colors: defaultColors)

    /// The default confetti shapes, located in the module bundle.
    static let defaultImages = (1...8).map {
        UIImage(named: String(format: "confetti_%02d", $0), in: .module, with: nil)!
    }

    /// The default tint colors, one per default image.
    static let defaultColors: [UIColor] = [
        .blue,
        .green,
        .yellow,
        .purple,
        .red,
        .cyan,
        UIColor(red: 1, green: 0.1, blue: 0, alpha: 1), // Orange
        UIColor(red: 1, green: 0.2, blue: 0, alpha: 1), // Gold
    ]

    /// Pairs each color with a default image, cycling through the images. An empty array uses the default colors.
    static func confetti(colors: [UIColor]) -> [C3DConfetti] {
        let colors = colors.isEmpty ? defaultColors : colors
        return colors.enumerated().map { index, color in
            C3DConfetti(image: defaultImages[index % defaultImages.count], color: color)
        }
    }
}

