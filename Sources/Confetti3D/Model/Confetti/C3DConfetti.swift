//
//  C3DConfetti.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

import UIKit

/// A single confetti element, consisting of an image and an optional color overlay.
public struct C3DConfetti: Sendable {

    /// The image used to render the confetti.
    let image: UIImage

    /// An optional tint color applied to the image.
    let color: UIColor?

    /// Initializes a new confetti element.
    ///
    /// - Parameters:
    ///   - image: The image to be used for the confetti shape.
    ///   - color: An optional color overlay applied to the image.
    public init(image: UIImage, color: UIColor?) {
        self.image = image
        self.color = color
    }
}
