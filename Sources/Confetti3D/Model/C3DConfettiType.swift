//
//  C3DConfettiType.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

/// Defines the type of confetti effect to be rendered.
///
/// - `confetti`: A classic confetti effect using a variety of shapes and colors.
/// - `glitter`: A glitter effect with warm, metallic-inspired tones for a more elegant or festive style.
public enum C3DConfettiType: Sendable {
    /// A confetti effect using the provided `C3DConfettiOptions`.
    case confetti(C3DConfettiOptions)
    
    /// A glitter effect using the provided `C3DGlitterOptions`.
    case glitter(C3DGlitterOptions)
}

extension C3DConfettiType {
    /// The default confetti type used by the system.
    ///
    /// Defaults to `.confetti` with `C3DConfettiOptions.defaultOptions`.
    /// This provides a colorful and playful visual effect.
    public static let `default`: C3DConfettiType = .confetti(.defaultOptions)
}
