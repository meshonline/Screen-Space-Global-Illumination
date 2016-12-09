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

vec3 normal_from_depth(vec2 texcoords) {
    // Delta coordinate of one pixel: 0.001 = 1 (pixel) / 1000 (pixels)
    const vec2 offset1 = vec2(0.0, 0.001);
    const vec2 offset2 = vec2(0.001, 0.0);
    
    // Fetch depth from depth buffer
    float depth = DecodeDepth(texture2D(sEmissiveMap, texcoords).rgb);
    float depth1 = DecodeDepth(texture2D(sEmissiveMap, texcoords + offset1).rgb);
    float depth2 = DecodeDepth(texture2D(sEmissiveMap, texcoords + offset2).rgb);
    
    highp vec3 p1 = vec3(offset1, depth1 - depth);
    highp vec3 p2 = vec3(offset2, depth2 - depth);
    
    // Calculate normal
    highp vec3 normal = cross(p1, p2);
    normal.z = -normal.z;
    
    return normalize(normal);
}

vec3 normal_from_pixels(vec2 texcoords1, vec2 texcoords2, out float dist) {
    // Fetch depth from depth buffer
    float depth1 = DecodeDepth(texture2D(sEmissiveMap, texcoords1).rgb);
    float depth2 = DecodeDepth(texture2D(sEmissiveMap, texcoords2).rgb);
    
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

    // Get the pixel color
    light_color = texture2D(sDiffMap, coord).rgb;
    // Calculate normal for the pixel
    light_normal = normal_from_depth(coord);
    // Calculate normal from the pixel to current pixel
    light_to_pixel_normal = normal_from_pixels(coord, vScreenPos, dist);
    // Calculate normal from current pixel to the pixel
    pixel_to_light_normal = -light_to_pixel_normal;

    // Calculate GI
    vec3 gi = light_color * max(0.0, dot(light_normal, light_to_pixel_normal)) * max(0.0, dot(pixel_normal, pixel_to_light_normal)) / dist;
    
    return gi;
}

void PS()
{
    vec3 pixel_normal;
    vec3 gi;

    // Calculate normal for current pixel
    pixel_normal = normal_from_depth(vScreenPos);
    // Prepare to accumulate GI
    gi = vec3(0.0);
 
    // Accumulate GI from some uniform samples
    for (int y=0; y<16; ++y) {
        for (int x=0; x<16; ++x) {
            gi += Calculate_GI(pixel_normal, vec2((float(x)+0.5)/16.0, (float(y)+0.5)/16.0));
        }
    }
    
    // Make GI not too strong
    gi /= 64.0;
    
    gl_FragColor = vec4(gi, 1.0);
}

#endif
