//
//  C3DGlitterOptions.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

import UIKit

public struct C3DGlitterOptions: Sendable {
    let confetti: [C3DConfetti]
    let isAffectedByGravity: Bool
    let birthRate: Int
    let emissionDuration: TimeInterval
    let lifeSpan: TimeInterval
    
    public init(confetti: [C3DConfetti],
                isAffectedByGravity: Bool,
                birthRate: Int,
                emissionDuration: TimeInterval,
                lifeSpan: TimeInterval) {
        self.confetti = confetti
        self.isAffectedByGravity = isAffectedByGravity
        self.birthRate = birthRate
        self.emissionDuration = emissionDuration
        self.lifeSpan = lifeSpan
    }
}

extension C3DGlitterOptions {
    public static let defaultOptions = C3DGlitterOptions(confetti: Constants.defaultGlitter,
                                                         isAffectedByGravity: true,
                                                         birthRate: 1000,
                                                         emissionDuration: 0.2,
                                                         lifeSpan: 10)
}

fileprivate enum Constants {
    static let defaultGlitterImage = UIImage(named: "confetti_08", in: .module, with: nil)!
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
