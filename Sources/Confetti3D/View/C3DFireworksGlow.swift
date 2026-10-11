import Foundation

/// A white-hot core, colored body and soft halo in the existing sprite draw.
/// Expanding the quad leaves room for glow without enlarging the bright core.
enum C3DFireworksGlow {
    static let diameterMultiplier: Float = 2.1

    static let stationaryGeometry = """
    #pragma varyings
    float2 c3d_sparkUV;
    float c3d_intensity;
    float c3d_heat;
    float c3d_ribbon;
    #pragma body
    out.c3d_sparkUV = _geometry.texcoords[0];
    out.c3d_intensity = 1.0;
    out.c3d_heat = 1.0;
    out.c3d_ribbon = 0.0;
    """

    static let fragment = """
    #pragma varyings
    float2 c3d_sparkUV;
    float c3d_intensity;
    float c3d_heat;
    float c3d_ribbon;
    #pragma body
    float2 p = (in.c3d_sparkUV - 0.5) * 2.0;
    // Ribbons fade across their width only: radial fading along each segment
    // would turn a continuous filament back into a row of separated beads.
    float radiusSquared = in.c3d_ribbon > 0.5 ? p.x * p.x : dot(p, p);
    if (radiusSquared >= 1.0) { discard_fragment(); }
    float edge = 1.0 - radiusSquared;
    float core = exp2(-140.0 * radiusSquared);
    float body = exp2(-16.0 * radiusSquared);
    float halo = exp2(-9.0 * radiusSquared) * edge * edge;
    float3 tint = _surface.multiply.rgb;
    float3 hot = mix(tint, float3(1.0), 0.94);
    float3 light = tint * (body * 0.45 + halo * 0.012)
        + hot * (core * 0.85 * in.c3d_heat);
    // Additive, already premultiplied radiance. The halo fades smoothly to zero
    // at the edge, without a full-screen bloom pass or extra geometry/emitters.
    _output.color = float4(light, halo) * (in.c3d_intensity * _surface.multiply.a);
    """
}
