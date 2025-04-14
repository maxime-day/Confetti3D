//
//  C3DConfettiOptions.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

import UIKit

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
                birthRate: Int = 40,
                emissionDuration: TimeInterval = 3,
                lifeSpan: TimeInterval = 10,
                size: CGFloat = 1) {
        self.confetti = confetti
        self.isAffectedByGravity = isAffectedByGravity
        self.birthRate = birthRate
        self.emissionDuration = emissionDuration
        self.lifeSpan = lifeSpan
        self.size = size
    }
}

extension C3DConfettiOptions {
    /// A predefined set of default confetti options using the default confetti assets.
    ///
    /// Includes 8 colorful confetti images with associated tint colors,
    /// default emission values, and gravity enabled.
    public static let defaultOptions = C3DConfettiOptions(confetti: Constants.defaultConfetti)
}

fileprivate enum Constants {
    /// The default confetti elements used in `C3DConfettiOptions.defaultOptions`.
    ///
    /// Each confetti is represented by a unique image located in the module bundle,
    /// and is paired with a specific color overlay to enhance visual diversity.
    static let defaultConfetti = [
        C3DConfetti(image: UIImage(named: "confetti_01", in: .module, with: nil)!,
                    color: .blue),
        C3DConfetti(image: UIImage(named: "confetti_02", in: .module, with: nil)!,
                    color: .green),
        C3DConfetti(image: UIImage(named: "confetti_03", in: .module, with: nil)!,
                    color: .yellow),
        C3DConfetti(image: UIImage(named: "confetti_04", in: .module, with: nil)!,
                    color: .purple),
        C3DConfetti(image: UIImage(named: "confetti_05", in: .module, with: nil)!,
                    color: .red),
        C3DConfetti(image: UIImage(named: "confetti_06", in: .module, with: nil)!,
                    color: .cyan),
        C3DConfetti(image: UIImage(named: "confetti_07", in: .module, with: nil)!,
                    color: UIColor(red: 1, green: 0.1, blue: 0, alpha: 1)), // Orange
        C3DConfetti(image: UIImage(named: "confetti_08", in: .module, with: nil)!,
                    color: UIColor(red: 1, green: 0.2, blue: 0, alpha: 1)), // Gold
    ]
}

