import SceneKit
import UIKit

/// One immutable, interleaved vertex buffer for all heads and trail ribbons in a
/// burst. SceneKit's vertex stage evaluates motion; the CPU only sends its age.
enum C3DFireworksBurstGeometry {
    static let trailSegmentsPerSecond: Float = 18
    static let trailLifeSpan: Float = 1
    static let trailLifeSpanVariation: Float = 0.15
    static let trailSlots = Int(ceil((trailLifeSpan + trailLifeSpanVariation) * trailSegmentsPerSecond)) + 1
    static let cleanupDuration = TimeInterval(trailLifeSpan + trailLifeSpanVariation) + 0.05

    // Reuse the immutable buffers for the standard particle count. Other counts
    // stay uncached so applications cannot grow an unbounded global cache.
    private static let defaultMesh = makeMesh(particleCount: 140)

    private static func makeMesh(particleCount: Int) -> SCNGeometry {
        var vertices: [Float] = []
        var indices: [UInt32] = []
        let spriteCount = particleCount * (trailSlots + 1) + 1
        vertices.reserveCapacity(spriteCount * 4 * 9)
        indices.reserveCapacity(spriteCount * 6)

        // Position stores velocity; mapping channel 1 stores lifetime scale/phase and
        // channel 2 stores trail slot/seed. The modifier replaces position on GPU.
        func appendSprite(velocity: SCNVector3, lifetime: Float, phase: Float, slot: Float, seed: Float) {
            let first = UInt32(vertices.count / 9)
            for uv: (Float, Float) in [(0, 0), (1, 0), (1, 1), (0, 1)] {
                vertices.append(contentsOf: [velocity.x, velocity.y, velocity.z, uv.0, uv.1,
                                             lifetime, phase, slot, seed])
            }
            indices.append(contentsOf: [first, first + 1, first + 2, first, first + 2, first + 3])
        }

        for _ in 0..<particleCount {
            let azimuth = Float.random(in: 0...(2 * .pi))
            let vertical = Float.random(in: -1...1)
            let radial = sqrt(1 - vertical * vertical)
            let speed = Float.random(in: 0.55...0.95)
            let velocity = SCNVector3(radial * cos(azimuth) * speed,
                                      vertical * speed, radial * sin(azimuth) * speed)
            let lifetime = Float.random(in: 0.8...1.2)
            let phase = Float.random(in: 0...(2 * .pi))
            let seed = Float.random(in: 0...1)
            appendSprite(velocity: velocity, lifetime: lifetime, phase: phase, slot: -1, seed: 0)
            for slot in 0..<trailSlots {
                appendSprite(velocity: velocity, lifetime: lifetime, phase: phase,
                             slot: Float(slot), seed: seed)
            }
        }
        appendSprite(velocity: SCNVector3Zero, lifetime: 0.1, phase: 0, slot: -2, seed: 0)

        let data = vertices.withUnsafeBytes { Data($0) }
        func source(_ semantic: SCNGeometrySource.Semantic, offset: Int, components: Int) -> SCNGeometrySource {
            SCNGeometrySource(data: data, semantic: semantic, vectorCount: vertices.count / 9,
                              usesFloatComponents: true, componentsPerVector: components,
                              bytesPerComponent: MemoryLayout<Float>.size,
                              dataOffset: offset * MemoryLayout<Float>.size,
                              dataStride: 9 * MemoryLayout<Float>.size)
        }
        let element = SCNGeometryElement(data: indices.withUnsafeBytes { Data($0) }, primitiveType: .triangles,
                                         primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<UInt32>.size)
        return SCNGeometry(sources: [source(.vertex, offset: 0, components: 3),
                                    source(.texcoord, offset: 3, components: 2),
                                    source(.texcoord, offset: 5, components: 2),
                                    source(.texcoord, offset: 7, components: 2)], elements: [element])
    }

    static func make(options: C3DFireworksOptions, color: UIColor) -> SCNGeometry {
        let mesh = options.particleCount == 140
            ? defaultMesh : makeMesh(particleCount: options.particleCount)
        // Sources and indices are shared, while the material/clock are individual.
        let geometry = SCNGeometry(sources: mesh.sources, elements: mesh.elements)
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = UIColor.white
        material.multiply.contents = color
        material.blendMode = .add
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        material.shaderModifiers = [.geometry: motionModifier, .fragment: C3DFireworksGlow.fragment]
        material.setValue(Float(0), forKey: "c3d_elapsed")
        material.setValue(Float(options.size), forKey: "c3d_size")
        material.setValue(Float(options.lifeSpan), forKey: "c3d_lifeSpan")
        geometry.firstMaterial = material

        // CPU-side culling cannot see vertex displacement. Bound the full motion,
        // including the largest velocity and trailing particles, rather than just
        // the initial velocity values in the source buffer.
        let duration = Float(options.lifeSpan * 1.2) + Float(cleanupDuration)
        let radius: Float = 0.95 / 0.65 + 0.2 * Float(options.size)
        let fall = 0.12 * duration / 0.65 + 0.1
        geometry.boundingBox = (SCNVector3(-radius, -radius - fall, -radius),
                                SCNVector3(radius, radius, radius))
        return geometry
    }

    private static let motionModifier = """
    #pragma arguments
    float c3d_elapsed;
    float c3d_size;
    float c3d_lifeSpan;
    #pragma varyings
    float2 c3d_sparkUV;
    float c3d_intensity;
    float c3d_heat;
    float c3d_ribbon;
    #pragma body
    float3 velocity = _geometry.position.xyz;
    float lifetime = _geometry.texcoords[1].x * c3d_lifeSpan;
    float phase = _geometry.texcoords[1].y;
    float slot = _geometry.texcoords[2].x;
    float seed = _geometry.texcoords[2].y;
    float t = max(0.0, c3d_elapsed);
    float motionTime = t;
    float intensity = 0.0;
    float heat = 1.0;
    float diameter = 0.016 * c3d_size;
    float ribbon = slot >= 0.0 ? 1.0 : 0.0;
    if (slot < -1.5) {
        // The initial flash is included in the same draw as the entire burst.
        intensity = max(0.0, 1.0 - t / 0.1);
        diameter = 0.12 * c3d_size;
        motionTime = 0.0;
    } else if (slot < 0.0) {
        float age = t / lifetime;
        intensity = max(0.0, 1.0 - age * age) * (0.82 + 0.18 * sin(t * 24.0 + phase));
        heat = 1.0 - clamp(age, 0.0, 1.0) * 0.35;
    } else {
        // Adjacent quads share their endpoints and sample the head's actual path.
        // Slide continuously behind it instead of recycling separate dot sprites.
        float span = \(trailLifeSpan) + (seed * 2.0 - 1.0) * \(trailLifeSpanVariation);
        float step = span / \(Float(trailSlots));
        motionTime = max(0.0, min(t, lifetime) - (slot + _geometry.texcoords[0].y) * step);
        float age = t - motionTime;
        float fraction = clamp(age / span, 0.0, 1.0);
        heat = (1.0 - fraction) * 0.45;
        float fade = (1.0 - fraction) * (1.0 - fraction);
        intensity = fade * 0.8;
        diameter = (0.008 + seed * 0.003) * c3d_size * (1.0 - fraction * 0.65);
    }
    motionTime = max(0.0, motionTime);
    float travel = (1.0 - exp(-0.65 * motionTime)) / 0.65;
    float fall = 0.12 * (motionTime - travel) / 0.65;
    float3 center = velocity * travel;
    center.y -= fall;
    float2 corner;
    if (ribbon > 0.5) {
        // Use the analytical tangent at each shared endpoint for seamless joins,
        // including where the trajectory bends down under gravity.
        float3 tangent = velocity * exp(-0.65 * motionTime);
        tangent.y -= 0.12 * travel;
        float2 viewTangent = (scn_node.modelViewTransform * float4(tangent, 0.0)).xy;
        float2 side = float2(-viewTangent.y, viewTangent.x) / max(length(viewTangent), 0.00001);
        corner = side * (_geometry.texcoords[0].x - 0.5) * diameter * \(C3DFireworksGlow.diameterMultiplier);
    } else {
        corner = (_geometry.texcoords[0] - 0.5) * diameter * \(C3DFireworksGlow.diameterMultiplier);
    }
    // Collapse invisible widths so expired ribbons cost no fragment work.
    corner *= intensity > 0.0 ? 1.0 : 0.0;
    float3 billboard = (scn_node.inverseModelViewTransform * float4(corner, 0.0, 0.0)).xyz;
    _geometry.position.xyz = center + billboard;
    out.c3d_sparkUV = _geometry.texcoords[0];
    out.c3d_intensity = intensity;
    out.c3d_heat = heat;
    out.c3d_ribbon = ribbon;
    """
}
