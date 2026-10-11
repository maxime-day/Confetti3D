import XCTest
import Metal
import SceneKit
@testable import Confetti3D

final class FireworksRenderingTests: XCTestCase {
    /// Includes SceneKit's scene update, command encoding and completed GPU work.
    /// Keep the same resolution and timestamps when comparing implementations.
    @MainActor
    func testSixSimultaneousExplosionsRenderingPerformance() throws {
        try measureRendering(frameCount: 90, makeScene: sixExplosions)
    }

    @MainActor
    func testSixRocketsIncludingDenseLaunchTrailsRenderingPerformance() throws {
        try measureRendering(frameCount: 180) {
            let scene = self.cameraScene()
            scene.rootNode.addChildNode(C3DFireworksEffect.makeNode(
                options: C3DFireworksOptions(count: 6, launchInterval: 0, particleCount: 140, horizontalSpread: 0.6)))
            return scene
        }
    }

    @MainActor
    private func measureRendering(frameCount: Int, makeScene: @escaping () -> SCNScene) throws {
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let queue = try XCTUnwrap(device.makeCommandQueue())
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm, width: 1170, height: 2532, mipmapped: false)
        descriptor.usage = .renderTarget
        let texture = try XCTUnwrap(device.makeTexture(descriptor: descriptor))
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = texture
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        let viewport = CGRect(x: 0, y: 0, width: 1170, height: 2532)

        measure(metrics: [XCTClockMetric()], options: {
            let options = XCTMeasureOptions()
            options.iterationCount = 3
            return options
        }()) {
            autoreleasepool {
                let renderer = SCNRenderer(device: device)
                renderer.scene = makeScene()
                renderer.pointOfView = renderer.scene?.rootNode.childNodes.first
                renderer.isPlaying = true
                for frame in 0..<frameCount {
                    let command = queue.makeCommandBuffer()!
                    renderer.render(atTime: Double(frame) / 30, viewport: viewport,
                                    commandBuffer: command, passDescriptor: pass)
                    command.commit()
                    command.waitUntilCompleted()
                    XCTAssertNil(command.error)
                }
            }
        }
    }

    @MainActor
    func testNormalizedPlaybackSpeedPreservesDefaultPaceAndScalesAnimation() throws {
        XCTAssertEqual(C3DFireworksOptions.defaultOptions.playbackSpeed, 1)
        let renderer = SCNRenderer(device: try XCTUnwrap(MTLCreateSystemDefaultDevice()))
        let scene = cameraScene()
        let normal = C3DFireworksEffect.makeBurst(color: .systemCyan, options: .defaultOptions)
        let slow = C3DFireworksEffect.makeBurst(color: .systemCyan,
                                               options: C3DFireworksOptions(playbackSpeed: 0.5))
        scene.rootNode.addChildNode(normal)
        scene.rootNode.addChildNode(slow)
        renderer.scene = scene
        renderer.isPlaying = true
        renderer.pointOfView = scene.rootNode.childNodes.first
        for frame in 0...30 {
            _ = renderer.snapshot(atTime: Double(frame) / 30, with: CGSize(width: 32, height: 32),
                                  antialiasingMode: .none)
        }
        let normalTime = try XCTUnwrap(normal.geometry?.firstMaterial?.value(forKey: "c3d_elapsed") as? NSNumber)
        let slowTime = try XCTUnwrap(slow.geometry?.firstMaterial?.value(forKey: "c3d_elapsed") as? NSNumber)
        XCTAssertEqual(normalTime.doubleValue, 0.7, accuracy: 0.03, "Speed 1 must retain the previously tuned pace")
        XCTAssertEqual(slowTime.doubleValue, normalTime.doubleValue * 0.5, accuracy: 0.01)
    }

    @MainActor
    func testExplosionRenderingProducesVisibleColoredTrails() throws {
        let renderer = SCNRenderer(device: try XCTUnwrap(MTLCreateSystemDefaultDevice()))
        renderer.scene = sixExplosions()
        renderer.pointOfView = renderer.scene?.rootNode.childNodes.first
        renderer.isPlaying = true
        for frame in 0...45 {
            renderer.update(atTime: Double(frame) / 30)
        }
        let image = renderer.snapshot(atTime: 1.5, with: CGSize(width: 390, height: 844), antialiasingMode: .none)
        let attachment = XCTAttachment(image: image)
        attachment.lifetime = .keepAlways
        add(attachment)
        let counts = try coloredPixels(image)
        XCTAssertGreaterThan(counts.cyan, 100)
        XCTAssertGreaterThan(counts.pink, 100)
        XCTAssertGreaterThan(counts.yellow, 100)
    }

    @MainActor
    func testIndividualSparksHaveWhiteCoresAndSoftColoredHalos() throws {
        let renderer = SCNRenderer(device: try XCTUnwrap(MTLCreateSystemDefaultDevice()))
        let scene = cameraScene()
        let burst = C3DFireworksEffect.makeBurst(color: .systemCyan,
                                                options: C3DFireworksOptions(particleCount: 12))
        burst.removeAllActions()
        burst.geometry!.firstMaterial!.setValue(Float(1.2), forKey: "c3d_elapsed")
        scene.rootNode.addChildNode(burst)
        renderer.scene = scene
        renderer.pointOfView = scene.rootNode.childNodes.first
        let image = renderer.snapshot(atTime: 0, with: CGSize(width: 1170, height: 2532), antialiasingMode: .none)
        let attachment = XCTAttachment(image: image)
        attachment.name = "White cores and cyan glow"
        attachment.lifetime = .keepAlways
        add(attachment)
        let pixels = try coloredPixels(image)
        XCTAssertGreaterThan(pixels.white, 8, "Individual cyan sparks must contain incandescent white cores")
        XCTAssertGreaterThan(pixels.softCyan, 30, "The glow must extend into a faint colored halo")
        XCTAssertGreaterThan(pixels.cyan, 100, "White cores must not erase the explosion color")
    }

    @MainActor
    func testTrailFormsAConnectedFilamentInsteadOfSeparatedDots() throws {
        let renderer = SCNRenderer(device: try XCTUnwrap(MTLCreateSystemDefaultDevice()))
        let scene = cameraScene()
        let burst = C3DFireworksEffect.makeBurst(color: .systemCyan,
                                                options: C3DFireworksOptions(particleCount: 1))
        burst.removeAllActions()
        burst.eulerAngles = SCNVector3Zero
        // A repeatable side-on trajectory, so a random direction towards the
        // camera cannot hide a broken trail by projecting it into a single dot.
        let original = try XCTUnwrap(burst.geometry)
        let vertices = SCNGeometrySource(vertices: Array(repeating: SCNVector3(0.85, 0.4, 0),
                                                         count: original.sources(for: .vertex)[0].vectorCount))
        let geometry = SCNGeometry(sources: [vertices] + original.sources(for: .texcoord),
                                   elements: original.elements)
        geometry.materials = original.materials
        geometry.boundingBox = original.boundingBox
        geometry.firstMaterial!.setValue(Float(1.2), forKey: "c3d_elapsed")
        burst.geometry = geometry
        scene.rootNode.addChildNode(burst)
        renderer.scene = scene
        renderer.pointOfView = scene.rootNode.childNodes.first
        let image = renderer.snapshot(atTime: 0, with: CGSize(width: 1170, height: 2532), antialiasingMode: .none)
        let attachment = XCTAttachment(image: image)
        attachment.name = "Continuous curved filament"
        attachment.lifetime = .keepAlways
        add(attachment)
        let pixels = try rgbaPixels(image)
        let width = image.cgImage!.width
        var remaining = Set(stride(from: 0, to: pixels.count, by: 4).compactMap { offset -> Int? in
            Int(pixels[offset + 1]) > Int(pixels[offset]) + 8 ? offset / 4 : nil
        })
        var largest = 0
        while let first = remaining.first {
            remaining.remove(first)
            var connected = [first]
            var cursor = 0
            while cursor < connected.count {
                let index = connected[cursor]
                for dy in -1...1 {
                    for dx in -1...1 where abs((index + dx) % width - index % width) <= 1 {
                        let neighbor = index + dy * width + dx
                        if remaining.remove(neighbor) != nil { connected.append(neighbor) }
                    }
                }
                cursor += 1
            }
            largest = max(largest, connected.count)
        }
        XCTAssertGreaterThan(largest, 100, "The visible trail must form a connected filament, rather than isolated glowing dots")
    }

    @MainActor
    func testTrailsOutliveHeadsAndEventuallyDisappear() throws {
        let renderer = SCNRenderer(device: try XCTUnwrap(MTLCreateSystemDefaultDevice()))
        let scene = sixExplosions()
        scene.rootNode.childNodes.dropFirst().forEach { $0.removeFromParentNode() }
        let burst = C3DFireworksEffect.makeBurst(color: .systemCyan,
                                                options: C3DFireworksOptions(particleCount: 20, lifeSpan: 1))
        burst.removeAllActions()
        scene.rootNode.addChildNode(burst)
        renderer.scene = scene
        renderer.pointOfView = scene.rootNode.childNodes.first
        let material = burst.geometry!.firstMaterial!
        // Even the longest-lived head has expired by age 1.2, but its emitted
        // sparks must remain visible instead of disappearing with the head.
        material.setValue(Float(1.4), forKey: "c3d_elapsed")
        let trails = renderer.snapshot(atTime: 0, with: CGSize(width: 390, height: 844), antialiasingMode: .none)
        XCTAssertGreaterThan(try coloredPixels(trails).cyan, 10)
        material.setValue(Float(2.5), forKey: "c3d_elapsed")
        let expired = renderer.snapshot(atTime: 0, with: CGSize(width: 390, height: 844), antialiasingMode: .none)
        XCTAssertEqual(try coloredPixels(expired).cyan, 0)
    }

    @MainActor
    func testSalvoRemovesRocketsAndBurstsAfterLastTrailExpires() throws {
        let renderer = SCNRenderer(device: try XCTUnwrap(MTLCreateSystemDefaultDevice()))
        let scene = sixExplosions()
        scene.rootNode.childNodes.dropFirst().forEach { $0.removeFromParentNode() }
        let salvo = C3DFireworksEffect.makeNode(options: .defaultOptions)
        scene.rootNode.addChildNode(salvo)
        renderer.scene = scene
        renderer.pointOfView = scene.rootNode.childNodes.first
        renderer.isPlaying = true
        for frame in 0...420 { renderer.update(atTime: Double(frame) / 30) }
        XCTAssertNil(salvo.parent)
        XCTAssertTrue(salvo.childNodes.isEmpty)
    }

    private func rgbaPixels(_ image: UIImage) throws -> [UInt8] {
        let cgImage = try XCTUnwrap(image.cgImage)
        var bytes = [UInt8](repeating: 0, count: cgImage.width * cgImage.height * 4)
        try bytes.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(data: buffer.baseAddress, width: cgImage.width, height: cgImage.height,
                                             bitsPerComponent: 8, bytesPerRow: cgImage.width * 4,
                                             space: CGColorSpaceCreateDeviceRGB(),
                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        }
        return bytes
    }

    private func coloredPixels(_ image: UIImage) throws -> (cyan: Int, pink: Int, yellow: Int, white: Int, softCyan: Int) {
        let bytes = try rgbaPixels(image)
        var cyan = 0, pink = 0, yellow = 0, white = 0, softCyan = 0
        for offset in stride(from: 0, to: bytes.count, by: 4) {
            let r = Int(bytes[offset]), g = Int(bytes[offset + 1]), b = Int(bytes[offset + 2])
            if g > r + 30 && b > r + 30 { cyan += 1 }
            // Keep detecting pink at low luminance with the deliberately faint glow.
            if r > g + 20 && b > g + 8 { pink += 1 }
            if r > b + 30 && g > b + 30 { yellow += 1 }
            // Incandescent cores can be white without clipping near full output.
            if min(r, g, b) > 150 && max(r, g, b) - min(r, g, b) < 80 { white += 1 }
            if g > r + 3 && b > r + 3 && max(g, b) > 8 && max(g, b) < 100 { softCyan += 1 }
        }
        return (cyan, pink, yellow, white, softCyan)
    }

    @MainActor
    private func sixExplosions() -> SCNScene {
        let scene = cameraScene()
        let colors: [UIColor] = [.systemCyan, .systemPink, .systemYellow]
        for index in 0..<6 {
            let burst = C3DFireworksEffect.makeBurst(color: colors[index % 3], options: .defaultOptions)
            burst.position = SCNVector3(Float(index % 3 - 1) * 0.4, Float(index / 3) * 0.5, 0)
            scene.rootNode.addChildNode(burst)
        }
        return scene
    }

    @MainActor
    private func cameraScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 0.1, 3.5)
        scene.rootNode.addChildNode(camera)
        return scene
    }

}
