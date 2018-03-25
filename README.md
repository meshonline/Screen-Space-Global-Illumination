# Screen Space Global Illumination
### Introduction
The idea is simple, we sample some pixels from screen space as independent light sources, the light positions are their screen space positions, the light directions are their screen space normals, then we accumulate lights from them as global illumination for every pixel.

Because we are working in screen space, it supports any light types and any light counts.

Low resolution mode is where the magic is, I use small quads (32x32 pixels) to calculate global illumination, and sample in uniform grids (16x16) of coordinates, since all calculations are in GPU, the speed is so fast that it always runs in realtime.

Screen space normal does not point to back, to lighten the back objects, I rendered another viewport buffer with front face culling mode, so only back faces are rendered, then I flip their normals to let them point to back.

I also use one blur pass to smooth the global illumination buffer, the lighting looks much smoother.

Finally, I blend the global illumination buffer onto the original viewport buffer.

That's all.

The shader can run on both desktop and mobile devices in realtime.

This formula is used to calculate global illumination:

GI = lightColor * max(0, dot(lightNormal, lightToPixelNormal)) * max(0, dot(pixelNormal, pixelToLightNormal)) / Distance;

It is a simplified version of physics based global illumination.

### SSGI Demo video clip
I use Urho3D game engine to test the effect, click the image to watch SSGI demo video clip:<br/>
[![ssgi.jpg](http://www.mesh-online.net/ssgi800x600.jpg)](https://youtu.be/M9cXRAHMhXY "SSGI Demo")

This SSGI demo video clip was captured from my iPad mini 2, the SSGI shader can run on mobile devices smoothly.

The green curtain and the red cloth bled amazing colors on the floor, and the wooden floor and the red cloth bled soft colors on the green curtain.

### License
The MIT License (MIT)
