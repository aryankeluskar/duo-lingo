#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// The press: paper, ink, and the halftone screen, drawn per pixel.

namespace riso {
  float hash(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
  }

  float2 hash2(float2 p) {
    float n = hash(p);
    return float2(n, hash(p + n + 17.17));
  }

  float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float a = hash(i);
    float b = hash(i + float2(1, 0));
    float c = hash(i + float2(0, 1));
    float d = hash(i + float2(1, 1));
    float2 u = f * f * (3 - 2 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
  }

  float fbm(float2 p) {
    float value = 0;
    float amplitude = 0.5;
    for (int octave = 0; octave < 4; octave++) {
      value += amplitude * noise(p);
      p = p * 2.03 + 11.7;
      amplitude *= 0.5;
    }
    return value / 0.9375;
  }

  float2 rotate(float2 p, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return float2(c * p.x - s * p.y, s * p.x + c * p.y);
  }
}

/// Screens a layer into halftone dots of one ink. The layer's opacity is the tone: each dot
/// grows with the tone beneath its center, a little unevenly, the way a drum lays down ink.
[[ stitchable ]] half4 risoHalftone(float2 position, SwiftUI::Layer layer, float pitch, float angle, half4 ink, float seed) {
  float2 lattice = riso::rotate(position, -angle) / pitch;
  float2 base = floor(lattice);
  float cover = 0;
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      float2 cell = base + float2(x, y) + 0.5;
      float2 jitter = (riso::hash2(cell + seed) - 0.5) * 0.16;
      float2 center = riso::rotate((cell + jitter) * pitch, angle);
      float tone = float(layer.sample(center).a);
      if (tone < 0.004) {
        continue;
      }
      // Some dots take more ink than others, and the inking drifts across the sheet.
      tone *= 0.84 + 0.32 * riso::hash(cell * 1.7 + seed);
      tone *= 0.78 + 0.44 * riso::noise(center * 0.05 + seed);
      float radius = pitch * 0.74 * sqrt(saturate(tone));
      float2 offset = position - center;
      float wobble = 1 + 0.16 * (riso::noise(offset * 1.6 + cell * 3.1) - 0.5);
      float reach = length(offset) * wobble;
      cover = max(cover, 1 - smoothstep(radius - 0.35, radius + 0.35, reach));
    }
  }
  cover *= 0.8 + 0.2 * riso::noise(position * 0.9 + seed * 3);
  return ink * half(cover);
}

/// A solid of ink as it prints: blotchy where the drum ran light, flecked where it skipped,
/// translucent enough that the paper glows through.
[[ stitchable ]] half4 risoInk(float2 position, half4 color, float seed) {
  float blotch = riso::fbm(position * 0.04 + seed);
  float fine = riso::noise(position * 1.3 + seed * 5);
  float density = 0.86 + 0.14 * smoothstep(0.2, 0.8, blotch);
  density *= 0.93 + 0.07 * fine;
  float speck = riso::hash(floor(position * 1.6) + seed);
  if (speck > 0.99) {
    density *= 0.3;
  }
  return color * half(density);
}

/// Roughens an edge by a fraction of a point, so type and rules sit in the paper.
[[ stitchable ]] float2 risoRoughen(float2 position, float seed) {
  float2 wander = float2(riso::noise(position * 0.8 + seed), riso::noise(position * 0.8 + seed + 31)) - 0.5;
  return position + wander * 0.8;
}

/// Uncoated stock: broad uneven tone, a cloudy formation, the tooth of the fibers, and light
/// falling away toward the edges of the sheet.
[[ stitchable ]] half4 risoPaper(float2 position, half4 color, float4 bounds) {
  float2 uv = (position - bounds.xy) / bounds.zw;
  float3 paper = float3(color.rgb);
  float broad = riso::fbm(position * 0.004) - 0.5;
  float cloud = riso::fbm(position * 0.035 + 7) - 0.5;
  float tooth = riso::noise(position * 0.75) - 0.5;
  float fiber = riso::noise(riso::rotate(position, 0.6) * float2(0.08, 1.1)) - 0.5;
  float shade = 1 + broad * 0.07 + cloud * 0.045 + tooth * 0.03 + fiber * 0.015;
  float2 edge = abs(uv - 0.5) * 2;
  float falloff = smoothstep(0.45, 1.2, length(edge * float2(1, 0.85)));
  shade -= falloff * 0.045;
  paper *= shade;
  // Shadowed paper goes warm, not gray.
  paper = mix(paper, paper * float3(1.0, 0.955, 0.87), saturate(falloff * 0.8 + max(0.0, -broad) * 0.6));
  float speck = riso::hash(floor(position * 2));
  if (speck > 0.9986) {
    paper *= 0.78;
  } else if (speck < 0.0025) {
    paper = mix(paper, float3(1), 0.4);
  }
  return half4(half3(paper), color.a);
}
