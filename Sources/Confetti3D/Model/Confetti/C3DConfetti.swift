//
//  C3DConfetti.swift
//  Confetti3D
//
//  Created by Maxime Daymard on 26/10/2024.
//

import UIKit

public struct C3DConfetti: Sendable {
    let image: UIImage
    let color: UIColor?
    
    public init(image: UIImage, color: UIColor?) {
        self.image = image
        self.color = color
    }
}
