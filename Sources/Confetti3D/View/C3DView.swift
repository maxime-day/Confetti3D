// The Swift Programming Language
// https://docs.swift.org/swift-book

import SceneKit
import CoreMotion
import SwiftUI
import Combine

public protocol ConfettiThrower {
    func throwConfetti(type: C3DConfettiType)
}

// For SwiftUI
public struct C3DView: UIViewRepresentable, ConfettiThrower {
    public typealias UIViewType = UIC3DView
    public typealias Context = UIViewRepresentableContext<C3DView>

    private let confettiView = UIC3DView()
    
    public init() {}

    public func updateUIView(_ uiView: UIViewType, context: Context) {
    }

    public func makeUIView(context: Context) -> UIViewType {
        return confettiView
    }
    
    public func throwConfetti(type: C3DConfettiType = .default) {
        confettiView.throwConfetti(type: type)
    }
}

// For UIKit
public final class UIC3DView: SCNView, ConfettiThrower {
    private lazy var motionManager = CMMotionManager()
    private lazy var mainParticlesNode = SCNNode()

    public init() {
        super.init(frame: .zero)
        setup()
    }

    public override init(frame: CGRect, options: [String: Any]? = nil) {
        super.init(frame: frame, options: options)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear
        scene.physicsWorld.gravity = SCNVector3(x: 0, y: -1, z: 0)
        scene.physicsWorld.speed = 6
        self.scene = scene

        mainParticlesNode.position = SCNVector3(0, 0.75, 0)
        scene.rootNode.addChildNode(mainParticlesNode)

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0.1, 3.5)

        let turbulenceNode = SCNNode()
        let turbulenceField = SCNPhysicsField.turbulenceField(smoothness: 0, animationSpeed: 0)
        scene.rootNode.addChildNode(turbulenceNode)
        turbulenceNode.position = SCNVector3(0, 0.5, -1)
        turbulenceNode.physicsField = turbulenceField
        turbulenceField.strength = 4
        turbulenceField.falloffExponent = 0
        turbulenceField.minimumDistance = 0

        let turbulenceNode2 = SCNNode()
        let turbulenceField2 = SCNPhysicsField.turbulenceField(smoothness: 0, animationSpeed: 0)
        scene.rootNode.addChildNode(turbulenceNode2)
        turbulenceNode2.position = SCNVector3(0, 0.2, -0.2)
        turbulenceNode2.physicsField = turbulenceField2
        turbulenceField2.strength = 4
        turbulenceField2.falloffExponent = 0
        turbulenceField2.minimumDistance = 0

        allowsCameraControl = false
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    public func throwConfetti(type: C3DConfettiType = .default) {
        print("Throwing confetti")
        
        switch type {
        case .confetti(let options):
            setupConfetti(with: options)
        case .glitter(let options):
            setupGlitter(with: options)
        }
    }

    private func setupConfetti(with options: C3DConfettiOptions) {
        let confetti = options.confetti
        
        let nbVariations = 2

        for _ in 1...nbVariations {
            for confetto in confetti {
                let particleSystem = SCNParticleSystem()
                particleSystem.particleImage = confetto.image
                particleSystem.particleColor = confetto.color ?? .white
                particleSystem.particleColorVariation = SCNVector4(0, 0, 0, 0)

                // Emitter
                particleSystem.birthRate = CGFloat(options.birthRate / nbVariations)
                particleSystem.emissionDuration = options.emissionDuration
                particleSystem.emittingDirection = SCNVector3(0, 1, 0)
                particleSystem.spreadingAngle = 40
                particleSystem.particleAngleVariation = 200
                particleSystem.particleAngle = 100
                // Simulation
                particleSystem.particleLifeSpan = options.lifeSpan
                particleSystem.particleVelocity = 2 + CGFloat.random(in: 0...0.01)

                particleSystem.particleAngularVelocity = CGFloat(Int.random(in: 100...400))
                particleSystem.particleAngularVelocityVariation = 100
                // Image
                particleSystem.particleSize = 0.05
                particleSystem.particleSizeVariation = 0.05
                
                // Rendering
                particleSystem.isBlackPassEnabled = true
                particleSystem.writesToDepthBuffer = true
                particleSystem.orientationMode = .free
                // Physics
                particleSystem.isAffectedByGravity = true
                particleSystem.isAffectedByPhysicsFields = true
                particleSystem.particleDiesOnCollision = false
                particleSystem.particleFriction = 100

                particleSystem.dampingFactor = 1
                particleSystem.acceleration = SCNVector3(0, 0.3, 0)

                particleSystem.particleMass = 1.5
                particleSystem.particleMassVariation = 0.005

                particleSystem.loops = false


                let particleSystemNode = SCNNode()
                particleSystemNode.addParticleSystem(particleSystem)
                mainParticlesNode.addChildNode(particleSystemNode)
                
                particleSystemNode.runAction(.fadeOut(duration: options.lifeSpan))
            }
        }

        if options.isAffectedByGravity {
            startDeviceMotionIfNeeded()
        }
    }

    private func setupGlitter(with options: C3DGlitterOptions) {
        
        let nbVariations = 20

        for index in 1...nbVariations {

            let particleSystem = SCNParticleSystem()
            particleSystem.particleImage = UIImage(named: "confetti_08", in: .module, with: nil)!

            particleSystem.particleColor = switch index {
            case 1...4:
                // Champagne pink – soft, warm highlight
                UIColor(red: 1.0, green: 0.84, blue: 0.72, alpha: 1.0)
            case 5...8:
                // Light copper – warm and vibrant orange tone
                UIColor(red: 0.95, green: 0.6, blue: 0.3, alpha: 1.0)
            case 9...12:
                // Warm bronze – deep, rich brown-gold
                UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
            case 13...16:
                // Deep rose gold – strong, saturated warm pink
                UIColor(red: 0.85, green: 0.5, blue: 0.4, alpha: 1.0)
            case 17...20:
                // Classic warm gold – balanced and bright
                UIColor(red: 1.0, green: 0.78, blue: 0.2, alpha: 1.0)
            default:
                // Fallback to warm gold
                UIColor(red: 1.0, green: 0.78, blue: 0.2, alpha: 1.0)
            }

            particleSystem.particleColorVariation = SCNVector4(0.01, 0.01, 0, 0)

            // Emitter
            particleSystem.birthRate = CGFloat(options.birthRate / nbVariations)
            particleSystem.emissionDuration = options.emissionDuration
            particleSystem.birthDirection = .random

            particleSystem.spreadingAngle = 20
            particleSystem.particleAngleVariation = 2000
            particleSystem.particleAngle = 360
            // Simulation
            particleSystem.particleLifeSpan = options.lifeSpan
            particleSystem.particleVelocity = 4
            particleSystem.particleVelocityVariation = 2

            particleSystem.particleAngularVelocity = CGFloat(Int.random(in:  500...1000))
            particleSystem.particleAngularVelocityVariation = 10
            // Image
            particleSystem.particleSize = 0.05
            particleSystem.particleSizeVariation = 0.01
            
            // Rendering
            particleSystem.isBlackPassEnabled = true
            particleSystem.writesToDepthBuffer = true
            particleSystem.orientationMode = .free
            // Physics
            particleSystem.isAffectedByGravity = true
            particleSystem.isAffectedByPhysicsFields = true
            particleSystem.particleDiesOnCollision = false
            particleSystem.particleFriction = 200
            particleSystem.dampingFactor = 1.8
            particleSystem.acceleration = SCNVector3(0, 0.3, 0)

            particleSystem.loops = false

            let particleSystemNode = SCNNode()
            particleSystemNode.position = SCNVector3(0, 0.5, 0)
            particleSystemNode.addParticleSystem(particleSystem)
            mainParticlesNode.addChildNode(particleSystemNode)
            
            particleSystemNode.runAction(.fadeOut(duration: options.lifeSpan))
        }

        if options.isAffectedByGravity {
            startDeviceMotionIfNeeded()
        }
    }

    private func startDeviceMotionIfNeeded() {
        guard !motionManager.isDeviceMotionActive,
              motionManager.isDeviceMotionAvailable else {
            return
        }
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            data.map {
                self?.updateGravity(with: $0)
            }
            error.map {
                print("Error getting device motion: \($0.localizedDescription)")
            }
        }
    }

    private func updateGravity(with data: CMDeviceMotion) {
        let gravity = data.gravity
        scene?.physicsWorld.gravity = SCNVector3(gravity.x, gravity.y, gravity.z)
    }
}
