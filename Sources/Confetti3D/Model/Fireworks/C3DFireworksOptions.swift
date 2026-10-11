import SceneKit
import UIKit

/// A staggered salvo of rising rockets and spherical, fading spark bursts.
public struct C3DFireworksOptions: Sendable {
    /// Cyan, ember red, warm gold, green and purple.
    public static let defaultColors: [UIColor] = [
        .systemCyan,
        UIColor(red: 1, green: 0.48, blue: 0.34, alpha: 1),
        UIColor(red: 1, green: 0.78, blue: 0.44, alpha: 1),
        .systemGreen,
        .systemPurple
    ]

    /// Global effect speed. 1 is normal speed; 0.7 plays all phases more slowly.
    public let playbackSpeed: CGFloat
    public let count: Int
    /// Each rocket cycles through this palette. An empty palette uses the default colors.
    public let colors: [UIColor]
    /// Delay between rockets at speed 1, in seconds.
    public let launchInterval: TimeInterval
    /// Multiplier for the size of the luminous heads and their trails.
    public let size: CGFloat
    /// Center of the launch area, in SceneKit scene units.
    public let position: SCNVector3

    // Tuned together to preserve the appearance and the bounded GPU workload.
    // These implementation details are not part of the public configuration.
    let flightDuration: TimeInterval
    let particleCount: Int
    let lifeSpan: TimeInterval
    let launchHeight: Float
    let horizontalSpread: Float

    public init(
        count: Int = 3,
        playbackSpeed: CGFloat = 0.7,
        colors: [UIColor] = C3DFireworksOptions.defaultColors,
        launchInterval: TimeInterval = 0.45,
        size: CGFloat = 1,
        position: SCNVector3 = SCNVector3(0, -1.2, 0)
    ) {
        self.init(count: count, playbackSpeed: playbackSpeed, colors: colors,
                  launchInterval: launchInterval, particleCount: 140, size: size, position: position)
    }

    /// Internal tuning entry point used by rendering tests with smaller fixtures.
    init(
        count: Int = 3,
        playbackSpeed: CGFloat = 0.7,
        colors: [UIColor] = C3DFireworksOptions.defaultColors,
        launchInterval: TimeInterval = 0.45,
        flightDuration: TimeInterval = 1.75,
        particleCount: Int,
        lifeSpan: TimeInterval = 3.2,
        size: CGFloat = 1,
        position: SCNVector3 = SCNVector3(0, -1.2, 0),
        launchHeight: Float = 1.8,
        horizontalSpread: Float = 0.35
    ) {
        self.playbackSpeed = max(0.1, playbackSpeed)
        self.count = max(0, count)
        self.colors = colors.isEmpty ? Self.defaultColors : colors
        self.launchInterval = max(0, launchInterval)
        self.flightDuration = max(0.1, flightDuration)
        self.particleCount = max(1, particleCount)
        self.lifeSpan = max(0.1, lifeSpan)
        self.size = max(0.1, size)
        self.position = position
        self.launchHeight = max(0.1, launchHeight)
        self.horizontalSpread = max(0, horizontalSpread)
    }

    public static let defaultOptions = C3DFireworksOptions()
}
