//
//  C3DGlitterOptions.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

import UIKit

/// Configuration options for the glitter particle system.
public struct C3DGlitterOptions: Sendable {
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

extension C3DGlitterOptions {
    /// A predefined set of glitter options using a single glitter image
    /// with multiple warm and metallic-inspired tint colors.
    ///
    /// This configuration is ideal for celebratory or elegant effects,
    /// using the same image tinted with variations like gold, copper, and rose.
    public static let defaultOptions = C3DGlitterOptions(confetti: Constants.defaultGlitter)
}

fileprivate enum Constants {
    /// The base glitter image used for all glitter particles.
    ///
    /// Loaded from the module bundle. This image is reused with different color overlays.
    static let defaultGlitterImage = UIImage(named: "confetti_08", in: .module, with: nil)!
    
    /// The default glitter configuration with a warm metallic color palette.
    ///
    /// Includes multiple `C3DConfetti` instances with the same base image but
    /// different tint colors such as orange, champagne pink, copper, bronze, and gold.
    static let defaultGlitter = [
        C3DConfetti(image: defaultGlitterImage,
                    color: .orange),
        C3DConfetti(image: defaultGlitterImage,
                    color: .white),
        C3DConfetti(image: defaultGlitterImage,
                    color: .brown),
        C3DConfetti(image: defaultGlitterImage,
                    color: UIColor(red: 1.0, green: 0.84, blue: 0.72, alpha: 1.0)), // Champagne pink
        C3DConfetti(image: defaultGlitterImage,
                    color: UIColor(red: 0.95, green: 0.6, blue: 0.3, alpha: 1.0)), // Light copper
        C3DConfetti(image: defaultGlitterImage,
                    color: UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)), // Warm bronze
        C3DConfetti(image: defaultGlitterImage,
                    color: UIColor(red: 0.85, green: 0.5, blue: 0.4, alpha: 1.0)), // Deep rose gold
        C3DConfetti(image: defaultGlitterImage,
                    color: UIColor(red: 1.0, green: 0.78, blue: 0.2, alpha: 1.0)), // Classic warm gold
    ]
}
