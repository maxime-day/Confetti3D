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

    /// A size multiplier for this element, on top of the size of the options.
    let size: CGFloat

    /// Initializes a new confetti element.
    ///
    /// - Parameters:
    ///   - image: The image to be used for the confetti shape.
    ///   - color: An optional color overlay applied to the image.
    public init(image: UIImage, color: UIColor?) {
        self.init(image: image, color: color, size: 1)
    }

    /// Initializes a new confetti element with its own size.
    ///
    /// - Parameters:
    ///   - image: The image to be used for the confetti shape.
    ///   - color: An optional color overlay applied to the image. `nil` keeps the image's original colors.
    ///   - size: A size multiplier for this element, on top of the size of the options. `1` is the default size.
    public init(image: UIImage, color: UIColor?, size: CGFloat) {
        self.image = image
        self.color = color
        self.size = max(0, size)
    }
}
