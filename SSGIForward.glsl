#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec2 vScreenPos;

#ifdef COMPILEVS

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vScreenPos = GetScreenPosPreDiv(gl_Position);
}

#endif


#ifdef COMPILEPS

vec3 normal_from_depth(sampler2D tex, vec2 texcoords) {
    // Delta coordinate of 1 pixel: 0.03125 = 1 (pixel) / 32 (pixels)
    const vec2 offset1 = vec2(0.0, 0.03125);
    const vec2 offset2 = vec2(0.03125, 0.0);
    
    // Fetch depth from depth buffer
    float depth = DecodeDepth(texture2D(tex, texcoords).rgb);
    float depth1 = DecodeDepth(texture2D(tex, texcoords + offset1).rgb);
    float depth2 = DecodeDepth(texture2D(tex, texcoords + offset2).rgb);
    
    highp vec3 p1 = vec3(offset1, depth1 - depth);
    highp vec3 p2 = vec3(offset2, depth2 - depth);
    
    // Calculate normal
    highp vec3 normal = cross(p1, p2);
    normal.z = -normal.z;
    
    return normalize(normal);
}

vec3 normal_from_pixels(sampler2D tex, vec2 texcoords1, vec2 texcoords2, out float dist) {
    // Fetch depth from depth buffer
    float depth1 = DecodeDepth(texture2D(tex, texcoords1).rgb);
    float depth2 = DecodeDepth(texture2D(tex, texcoords2).rgb);
    
    // Calculate normal
    highp vec3 normal = vec3(texcoords2 - texcoords1, depth2 - depth1);
    normal.z = -normal.z;
    
    // Calculate distance between texcoords
    dist = length(normal);
    
    return normalize(normal);
}

vec3 Calculate_GI(vec3 pixel_normal, vec2 coord)
{
    vec3 light_color;
    vec3 pixel_to_light_normal;
    vec3 light_normal, light_to_pixel_normal;
    float dist;
    float pixel_to_light_dot;
    vec3 gi = vec3(0.0);
    
    // Calculate normal from the pixel to current pixel
    light_to_pixel_normal = normal_from_pixels(sEmissiveMap, coord, vScreenPos, dist);
    // Calculate normal from current pixel to the pixel
    pixel_to_light_normal = -light_to_pixel_normal;
    // Calculate dot product from current pixel to the pixel
    pixel_to_light_dot = max(0.0, dot(pixel_normal, pixel_to_light_normal));
    
    // Get the pixel color
    light_color = texture2D(sDiffMap, coord).rgb;
    // Calculate normal for the pixel
    light_normal = normal_from_depth(sEmissiveMap, coord);
    // Calculate GI
    gi += light_color * max(0.0, dot(light_normal, light_to_pixel_normal)) * pixel_to_light_dot / dist;
    
    // Get the cull pixel color, base color need to be lighten to simulate direct light effect.
    light_color = texture2D(sEnvMap, coord).rgb * 8.0;
    // Calculate normal for the cull pixel
    light_normal = normal_from_depth(sNormalMap, coord);
    // Flip the normal
    light_normal = -light_normal;
    
    // Calculate GI
    gi += light_color * max(0.0, dot(light_normal, light_to_pixel_normal)) * pixel_to_light_dot / dist;
    
    return gi;
}

void PS()
{
    const int GRID_COUNT = 9;
    vec3 pixel_normal;
    vec3 gi;
    
    // Calculate normal for current pixel
    pixel_normal = normal_from_depth(sEmissiveMap, vScreenPos);
    // Prepare to accumulate GI
    gi = vec3(0.0);
    
    // Accumulate GI from some uniform samples
    for (int y = 0; y < GRID_COUNT; ++y) {
        for (int x = 0; x < GRID_COUNT; ++x) {
            gi += Calculate_GI(pixel_normal, vec2((float(x) + 0.5) / float(GRID_COUNT), (float(y) + 0.5) / float(GRID_COUNT)));
        }
    }
    
    // Make GI not too strong
    gi /= float(GRID_COUNT * GRID_COUNT / 3);
    
    gl_FragColor = vec4(gi, 1.0);
}

#endif
