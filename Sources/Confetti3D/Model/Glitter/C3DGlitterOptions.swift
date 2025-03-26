//
//  C3DGlitterOptions.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

import UIKit

public struct C3DGlitterOptions: Sendable {
    let isAffectedByGravity: Bool
    let birthRate: Int
    let emissionDuration: TimeInterval
    let lifeSpan: TimeInterval
    
    public init(isAffectedByGravity: Bool,
                birthRate: Int,
                emissionDuration: TimeInterval,
                lifeSpan: TimeInterval) {
        self.isAffectedByGravity = isAffectedByGravity
        self.birthRate = birthRate
        self.emissionDuration = emissionDuration
        self.lifeSpan = lifeSpan
    }
}

extension C3DGlitterOptions {
    public static let defaultOptions = C3DGlitterOptions(isAffectedByGravity: true,
                                                      birthRate: 2000,
                                                      emissionDuration: 0.2,
                                                      lifeSpan: 10)
}
