# Screen Space Global Illumination
The idea is simple, to calculate full global illumination, the best way is to treat every pixel as a light source, we can accumulate lights from all pixels as global illumination for every pixel.

Low resolution mode is the secret, I use a small screen of 8 x 8 pixels to calculate the full global illumination, all calculations are in GPU with a brief GLSL shader, the speed is so fast that it always runs in realtime.

Finally, I blend the global illumination to the original viewport.

That's all.

This formula is used to calculate global illumination:

GI = lightColor * max(0, dot(lightNormal, lightToPixelNormal)) * max(0, dot(pixelNormal, pixelToLightNormal))

I use Urho3D game engine to test the effect, here is a screenshot:

![ssgi.jpg](http://www.mesh-online.net/ssgi.jpg)

Notice the color bleeding effect on the floor, the green curtain and the red cloth bled amazing colors on the floor, and the wood floor also bled soft colors on the green curtain.

### TODO
This is just an experiment, there are a few issues to be fixed.

Edit: I have improved the algorithm by adding blur pass and calculating GI by distance, the GI looks more naturally now.

### License
The MIT License (MIT)
