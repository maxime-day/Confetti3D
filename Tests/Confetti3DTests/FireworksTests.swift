import XCTest
@testable import Confetti3D
import SceneKit

final class FireworksTests: XCTestCase {
    @MainActor
    func testSalvoCreationPerformance() {
        let options = C3DFireworksOptions()
        measure(metrics: [XCTClockMetric()]) {
            autoreleasepool {
                let salvo = C3DFireworksEffect.makeNode(options: options)
                XCTAssertTrue(salvo.hasActions)
            }
        }
    }

    @MainActor
    func testSixBurstsKeepAllStarsInSixDrawBatchesWithoutEmitters() {
        let options = C3DFireworksOptions(particleCount: 140)
        let parent = SCNNode()
        for _ in 0..<6 {
            parent.addChildNode(C3DFireworksEffect.makeBurst(color: .systemCyan, options: options))
        }
        XCTAssertEqual(parent.childNodes.count, 6)
        XCTAssertTrue(parent.childNodes[0].geometry?.sources.first === parent.childNodes[1].geometry?.sources.first)
        XCTAssertFalse(parent.childNodes[0].geometry?.firstMaterial === parent.childNodes[1].geometry?.firstMaterial)
        for burst in parent.childNodes {
            XCTAssertTrue(burst.childNodes.isEmpty)
            XCTAssertTrue(burst.particleSystems?.isEmpty ?? true)
            let geometry = burst.geometry!
            XCTAssertEqual(geometry.elements.count, 1)
            let sprites = 140 * (C3DFireworksBurstGeometry.trailSlots + 1) + 1
            XCTAssertEqual(geometry.elements[0].primitiveCount, sprites * 2)
            XCTAssertEqual(geometry.sources(for: .vertex)[0].vectorCount, sprites * 4)
            XCTAssertEqual(geometry.sources(for: .texcoord).count, 3)
            XCTAssertEqual(geometry.firstMaterial?.multiply.contents as? UIColor, .systemCyan)
            XCTAssertNotNil(geometry.firstMaterial?.shaderModifiers?[.geometry])
            XCTAssertTrue(burst.hasActions)
        }
    }

    func testRibbonSegmentsCoverTrailDurationWithinExistingGeometryBudget() {
        let slots = C3DFireworksBurstGeometry.trailSlots
        let maxLife = C3DFireworksBurstGeometry.trailLifeSpan + C3DFireworksBurstGeometry.trailLifeSpanVariation
        XCTAssertGreaterThanOrEqual(Float(slots), maxLife * C3DFireworksBurstGeometry.trailSegmentsPerSecond)
        XCTAssertGreaterThan(C3DFireworksBurstGeometry.trailLifeSpan, 0.55)
        XCTAssertEqual(slots, 22, "Connected trails reuse the existing quad budget")
        XCTAssertGreaterThan(C3DFireworksEffect.starTrailCleanupDuration, TimeInterval(maxLife))
    }

    func testAscentStartsAndEndsAtRequestedPositions() {
        let start = SCNVector3(-0.3, -1.2, 0.1)
        let end = SCNVector3(0.2, 0.8, -0.1)
        let first = C3DFireworksEffect.flightPosition(start: start, end: end, bend: 0.12, progress: 0)
        let last = C3DFireworksEffect.flightPosition(start: start, end: end, bend: 0.12, progress: 1)
        XCTAssertEqual(first.x, start.x, accuracy: 0.0001)
        XCTAssertEqual(first.y, start.y, accuracy: 0.0001)
        XCTAssertEqual(first.z, start.z, accuracy: 0.0001)
        XCTAssertEqual(last.x, end.x, accuracy: 0.0001)
        XCTAssertEqual(last.y, end.y, accuracy: 0.0001)
        XCTAssertEqual(last.z, end.z, accuracy: 0.0001)
    }

    func testRocketSlowsButKeepsRisingUntilDetonation() {
        let start = SCNVector3(0, -1, 0)
        let end = SCNVector3(0.2, 1, 0)
        let points = (0...10).map {
            C3DFireworksEffect.flightPosition(start: start, end: end, bend: 0.1, progress: Float($0) / 10)
        }
        for index in 1..<points.count {
            XCTAssertGreaterThan(points[index].y, points[index - 1].y)
        }
        XCTAssertGreaterThan(points[1].y - points[0].y, points[10].y - points[9].y)
        // Slow enough to read visually, while keeping positive upward motion.
        XCTAssertLessThan(points[10].y - points[9].y, (points[1].y - points[0].y) * 0.1)
        let nearlyThere = C3DFireworksEffect.flightPosition(start: start, end: end, bend: 0.1, progress: 0.99)
        XCTAssertLessThan(nearlyThere.y, end.y)
        XCTAssertGreaterThan(points[5].x, (start.x + end.x) / 2)
    }

    func testBurstExpandsWithAirResistanceBeforeFalling() {
        let velocity = SCNVector3(0.8, 0.6, 0)
        let origin = C3DFireworksEffect.burstPosition(velocity: velocity, elapsed: 0)
        let early = C3DFireworksEffect.burstPosition(velocity: velocity, elapsed: 1)
        let middle = C3DFireworksEffect.burstPosition(velocity: velocity, elapsed: 2)
        let late = C3DFireworksEffect.burstPosition(velocity: velocity, elapsed: 4)
        XCTAssertEqual(origin.x, 0)
        XCTAssertEqual(origin.y, 0)
        XCTAssertGreaterThan(early.y, 0)
        XCTAssertGreaterThan(middle.x, early.x)
        XCTAssertLessThan(middle.x - early.x, early.x)
        XCTAssertLessThan(late.y, middle.y)
    }

    func testHorizontalSparksDoNotImmediatelyPlummet() {
        let velocity = SCNVector3(0.8, 0, 0)
        let point = C3DFireworksEffect.burstPosition(velocity: velocity, elapsed: 1)
        XCTAssertGreaterThan(point.x, 0.5)
        XCTAssertGreaterThan(point.y, -0.06)
        XCTAssertLessThan(point.y, 0)
    }

    func testEmptyPaletteAndInvalidDurationsHaveUsableDefaults() {
        let options = C3DFireworksOptions(count: -1, playbackSpeed: 0, colors: [], launchInterval: -2,
                                          flightDuration: 0, particleCount: 0, lifeSpan: 0,
                                          size: 0, launchHeight: -1, horizontalSpread: -1)
        XCTAssertGreaterThan(options.playbackSpeed, 0)
        XCTAssertEqual(options.count, 0)
        XCTAssertFalse(options.colors.isEmpty)
        XCTAssertEqual(options.launchInterval, 0)
        XCTAssertGreaterThan(options.flightDuration, 0)
        XCTAssertGreaterThan(options.particleCount, 0)
        XCTAssertGreaterThan(options.lifeSpan, 0)
        XCTAssertGreaterThan(options.size, 0)
        XCTAssertGreaterThan(options.launchHeight, 0)
        XCTAssertEqual(options.horizontalSpread, 0)
    }
}
