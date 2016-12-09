# Screen Space Global Illumination
The idea is simple, we sample some pixels from screen space, treat them as independent light sources, the light directions are their normals, then we accumulate lights from them as global illumination for every pixel.

Because we are working in screen space, it support any light types and any light numbers.

Low resolution mode is the secret, I use a small screen (32x32 pixels) to calculate global illumination, and sample in uniform coordinates, all calculations are in GPU with a GLSL shader, the speed is so fast that it always runs in realtime.

I also use two blur passes to smooth the depth buffer and the global illumination buffer, the lighting looks more smoothly than ever.

Finally, I blend the global illumination to the original viewport.

That's all.

It can run on both desktop and mobile devices in realtime now.

Enjoy it.

This formula is used to calculate global illumination:

GI = lightColor * max(0, dot(lightNormal, lightToPixelNormal)) * max(0, dot(pixelNormal, pixelToLightNormal)) / Distance;

I use Urho3D game engine to test the effect, here is a screenshot:

![ssgi.jpg](http://www.mesh-online.net/ssgi.jpg)

Notice the color bleeding effect on the floor, the green curtain and the red cloth bled amazing colors on the floor, and the wood floor also bled soft colors on the green curtain.

### License
The MIT License (MIT)
