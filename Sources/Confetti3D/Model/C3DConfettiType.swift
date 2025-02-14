//
//  C3DConfettiType.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

public enum C3DConfettiType: Sendable {
    case confetti(C3DConfettiOptions)
    case glitter(C3DGlitterOptions)
}

extension C3DConfettiType {
    public static let `default`: C3DConfettiType = .confetti(.defaultOptions)
}
