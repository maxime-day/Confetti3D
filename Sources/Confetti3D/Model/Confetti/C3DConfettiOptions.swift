//
//  C3DConfettiOptions.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

import UIKit

public struct C3DConfettiOptions: Sendable {
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

extension C3DConfettiOptions {
    public static let defaultOptions = C3DConfettiOptions(confetti: Constants.defaultConfetti,
                                                         isAffectedByGravity: true,
                                                         birthRate: 40,
                                                         emissionDuration: 3,
                                                         lifeSpan: 10)
}

fileprivate enum Constants {
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

