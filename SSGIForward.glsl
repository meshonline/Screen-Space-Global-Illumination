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
    // One pixel: 0.001 = 1 / 1000 (pixels)
    const vec2 offset1 = vec2(0.0, 0.001);
    const vec2 offset2 = vec2(0.001, 0.0);
    
    float depth = DecodeDepth(texture2D(sDepthBuffer, texcoords).rgb);
    float depth1 = DecodeDepth(texture2D(sDepthBuffer, texcoords + offset1).rgb);
    float depth2 = DecodeDepth(texture2D(sDepthBuffer, texcoords + offset2).rgb);
    
    vec3 p1 = vec3(offset1, depth1 - depth);
    vec3 p2 = vec3(offset2, depth2 - depth);
    
    highp vec3 normal = cross(p1, p2);
    normal.z = -normal.z;
    
    return normalize(normal);
}

vec3 normal_from_pixels(vec2 texcoords1, vec2 texcoords2) {
    float depth1 = DecodeDepth(texture2D(sDepthBuffer, texcoords1).rgb);
    float depth2 = DecodeDepth(texture2D(sDepthBuffer, texcoords2).rgb);
    
    highp vec3 normal = vec3(texcoords2 - texcoords1, depth2 - depth1);
    normal.z = -normal.z;
    
    return normalize(normal);
}

vec3 Calculate_GI(vec3 pixel_normal, vec2 coord)
{
    vec3 light_color;
    vec3 pixel_to_light_normal;
    vec3 light_normal, light_to_pixel_normal;
    // Get the pixel color
    light_color = texture2D(sDiffMap, coord).rgb;
    // Calculate normal for the pixel
    light_normal = normal_from_depth(coord);
    // Calculate normal from the pixel to current pixel
    light_to_pixel_normal = normal_from_pixels(coord, vScreenPos);
    // Calculate normal from current pixel to the pixel
    pixel_to_light_normal = -light_to_pixel_normal;
    // Calculate GI
    return light_color * max(0.0, dot(light_normal, light_to_pixel_normal)) * max(0.0, dot(pixel_normal, pixel_to_light_normal));
}

void PS()
{
    vec3 pixel_normal;
    vec3 gi;

    // Calculate normal for current pixel
    pixel_normal = normal_from_depth(vScreenPos);
    // Prepare to accumulate GI
    gi = vec3(0.0);
 
    // Accumulate GI
    for (int y=0; y<8; ++y) {
        for (int x=0; x<8; ++x) {
            gi += Calculate_GI(pixel_normal, vec2((float(x)+0.5)/8.0, (float(y)+0.5)/8.0));
        }
    }
    
    gi *= 0.1;
    
    gl_FragColor = vec4(gi, 1.0);
}

#endif
