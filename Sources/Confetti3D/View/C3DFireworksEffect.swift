import SceneKit
import UIKit

/// Builds a self-contained salvo. All delayed work belongs to scene actions, so
/// removing the scene also cancels pending launches without timers or retained views.
enum C3DFireworksEffect {
    // Immutable, lazily initialized once; all salvos reuse the same sprite.
    private static let texture = sparkTexture()
    private static let rocketTrailLifeSpan: TimeInterval = 0.9
    private static let trailLifeSpanVariation: TimeInterval = 0.15
    private static let rocketTrailCleanupDuration = rocketTrailLifeSpan + trailLifeSpanVariation + 0.05
    static let starTrailCleanupDuration = C3DFireworksBurstGeometry.cleanupDuration

    static func preparationGeometry() -> SCNGeometry {
        C3DFireworksBurstGeometry.make(options: .defaultOptions, color: .white)
    }

    static func makeNode(options: C3DFireworksOptions) -> SCNNode {
        let salvo = SCNNode()
        salvo.name = "C3DFireworks"
        guard options.count > 0 else { return salvo }

        for index in 0..<options.count {
            let color = options.colors[index % options.colors.count]
            let duration = options.flightDuration * Double.random(in: 0.88...1.12) / Double(options.playbackSpeed)
            let start = SCNVector3(
                options.position.x + Float.random(in: -options.horizontalSpread...options.horizontalSpread),
                options.position.y,
                options.position.z + Float.random(in: -0.1...0.1)
            )
            let end = SCNVector3(
                start.x + Float.random(in: -0.18...0.18),
                start.y + options.launchHeight * Float.random(in: 0.85...1.15),
                start.z + Float.random(in: -0.15...0.15)
            )
            let bend = Float.random(in: -0.12...0.12)
            let rocket = rocketNode(texture: texture, size: options.size, playbackSpeed: options.playbackSpeed)
            rocket.position = start
            let explosion = makeBurst(color: color, options: options)
            explosion.position = end

            let launch = SCNAction.run { parent in
                parent.addChildNode(rocket)
                rocket.runAction(.sequence([
                    .customAction(duration: duration) { node, elapsed in
                        let progress = min(Float(elapsed / CGFloat(duration)), 1)
                        node.position = flightPosition(start: start, end: end, bend: bend, progress: progress)
                    },
                    .run { node in
                        node.position = end
                        node.geometry = nil
                        node.particleSystems?.forEach { $0.birthRate = 0 }
                        node.parent?.addChildNode(explosion)
                    },
                    // Keep the emitter alive until its already-emitted trail has faded.
                    .wait(duration: rocketTrailCleanupDuration / Double(options.playbackSpeed)),
                    .removeFromParentNode()
                ]))
            }
            salvo.runAction(.sequence([
                .wait(duration: Double(index) * options.launchInterval / Double(options.playbackSpeed)), launch
            ]))
        }

        let totalDuration = (Double(options.count - 1) * options.launchInterval
            + options.flightDuration * 1.12 + max(rocketTrailCleanupDuration, options.lifeSpan * 1.2 + starTrailCleanupDuration + 0.05) + 0.2)
            / Double(options.playbackSpeed)
        salvo.runAction(.sequence([.wait(duration: totalDuration), .removeFromParentNode()]))
        return salvo
    }

    /// A slowing ascent that detonates just before the apex, while still rising.
    static func flightPosition(start: SCNVector3, end: SCNVector3, bend: Float, progress: Float) -> SCNVector3 {
        let t = min(max(progress, 0), 1)
        // Almost reach the apex, leaving a clearly visible slow final ascent.
        // Use the same easing for lateral drift so the whole projectile slows.
        let ascent = 1.95 * t - 0.95 * t * t
        return SCNVector3(
            start.x + (end.x - start.x) * ascent + bend * sin(.pi * ascent),
            start.y + (end.y - start.y) * ascent,
            start.z + (end.z - start.z) * ascent
        )
    }

    private static func rocketNode(texture: UIImage, size: CGFloat, playbackSpeed: CGFloat) -> SCNNode {
        let gold = UIColor(red: 1, green: 0.72, blue: 0.25, alpha: 1)
        let rocket = glowingNode(color: gold, size: 0.0125 * size)
        rocket.name = "C3DFireworksRocket"

        // This cached exhaust texture contains its own white core and gold halo.
        let trail = particles(texture: texture, color: .white, size: 0.075 * size, lifeSpan: rocketTrailLifeSpan)
        trail.speedFactor = playbackSpeed
        // Only one emitter per rocket: a dense, narrow exhaust is inexpensive
        // now that explosions no longer create an emitter for every star.
        trail.birthRate = 120
        trail.loops = true
        trail.emitterShape = SCNSphere(radius: 0.0025 * size)
        trail.emittingDirection = SCNVector3(0, -1, 0)
        trail.spreadingAngle = 8
        trail.particleVelocity = 0.1
        trail.particleVelocityVariation = 0.035
        trail.particleLifeSpanVariation = trailLifeSpanVariation
        trail.particleSizeVariation = 0.018 * size
        trail.acceleration = SCNVector3(0, -0.1, 0)
        trail.dampingFactor = 0.35
        rocket.addParticleSystem(trail)
        return rocket
    }

    static func makeBurst(color: UIColor, options: C3DFireworksOptions) -> SCNNode {
        let geometry = C3DFireworksBurstGeometry.make(options: options, color: color)
        let burst = SCNNode(geometry: geometry)
        burst.name = "C3DFireworksBurst"
        // Rotate shared spherical velocity data so overlapping bursts stay varied.
        burst.eulerAngles.y = Float.random(in: 0...(2 * .pi))
        let material = geometry.firstMaterial!
        let duration = (options.lifeSpan * 1.2 + starTrailCleanupDuration + 0.05) / Double(options.playbackSpeed)
        burst.runAction(.sequence([
            // One scalar update per explosion; no per-star nodes, constraints,
            // native emitters, buffer uploads, or CPU trajectory loop per frame.
            .customAction(duration: duration) { _, elapsed in
                material.setValue(Float(elapsed * options.playbackSpeed), forKey: "c3d_elapsed")
            },
            .removeFromParentNode()
        ]))
        return burst
    }

    /// Linear air resistance and gentle gravity: the burst expands before its
    /// stars arc downwards. Closed-form motion stays consistent at any frame rate.
    static func burstPosition(velocity: SCNVector3, elapsed: Float) -> SCNVector3 {
        let motion = burstMotion(elapsed: elapsed)
        return SCNVector3(velocity.x * motion.travel,
                          velocity.y * motion.travel - motion.fall,
                          velocity.z * motion.travel)
    }

    private static func burstMotion(elapsed: Float) -> (travel: Float, fall: Float) {
        let t = max(0, elapsed)
        let drag: Float = 0.65
        let gravity: Float = 0.12
        let travel = (1 - exp(-drag * t)) / drag
        return (travel, gravity * (t - travel) / drag)
    }

    private static func glowingNode(color: UIColor, size: CGFloat) -> SCNNode {
        let node = SCNNode(geometry: glowingGeometry(color: color, size: size))
        node.constraints = [SCNBillboardConstraint()]
        return node
    }

    private static func glowingGeometry(color: UIColor, size: CGFloat) -> SCNGeometry {
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = UIColor.white
        material.multiply.contents = color
        material.blendMode = .add
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        material.isDoubleSided = true
        material.shaderModifiers = [.geometry: C3DFireworksGlow.stationaryGeometry,
                                    .fragment: C3DFireworksGlow.fragment]
        let diameter = size * CGFloat(C3DFireworksGlow.diameterMultiplier)
        let plane = SCNPlane(width: diameter, height: diameter)
        plane.firstMaterial = material
        return plane
    }

    private static func particles(
        texture: UIImage, color: UIColor, size: CGFloat, lifeSpan: TimeInterval
    ) -> SCNParticleSystem {
        let system = SCNParticleSystem()
        system.particleImage = texture
        system.particleColor = color
        system.particleSize = size
        system.particleLifeSpan = lifeSpan
        system.loops = false
        // World-space particles leave a real trail instead of following their emitter.
        system.isLocal = false
        system.isLightingEnabled = false
        system.blendMode = .additive
        system.orientationMode = .billboardScreenAligned
        system.writesToDepthBuffer = false
        // Keep fireworks independent of device motion and the confetti turbulence fields.
        system.isAffectedByGravity = false
        system.isAffectedByPhysicsFields = false

        let opacity = CAKeyframeAnimation()
        opacity.values = [1, 1, 0.65, 0]
        opacity.keyTimes = [0, 0.15, 0.55, 1]
        let scale = CAKeyframeAnimation()
        scale.values = [size, size * 0.85, size * 0.2]
        scale.keyTimes = [0, 0.5, 1]
        system.propertyControllers = [
            .opacity: SCNParticlePropertyController(animation: opacity),
            .size: SCNParticlePropertyController(animation: scale)
        ]
        return system
    }

    /// Native rocket exhaust uses the same incandescent appearance, baked once.
    private static func sparkTexture() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 32, height: 32), format: format).image { context in
            let gold = UIColor(red: 1, green: 0.72, blue: 0.25, alpha: 1)
            let colors = [UIColor.white.cgColor,
                          UIColor(red: 1, green: 0.93, blue: 0.72, alpha: 1).cgColor,
                          gold.withAlphaComponent(0.7).cgColor,
                          gold.withAlphaComponent(0.12).cgColor,
                          gold.withAlphaComponent(0).cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors,
                                            locations: [0, 0.12, 0.3, 0.65, 1]) else { return }
            context.cgContext.drawRadialGradient(gradient, startCenter: CGPoint(x: 16, y: 16), startRadius: 0,
                                                  endCenter: CGPoint(x: 16, y: 16), endRadius: 16, options: [])
        }
    }
}
