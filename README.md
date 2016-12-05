# Screen Space Global Illumination
The idea is simple, gather light from every pixel as global illumination for every pixel in low resolution mode.

GI = lightColor * max(0, dot(lightNormal, lightToPixelNormal)) * max(0, dot(pixelNormal, pixelToLightNormal))

I use Urho3D game engine to test the effect, the resolution is 8 x 8, it can run in realtime!

![SSGI Screenshot](http://www.mesh-online.net/ssgi-demo.jpg)

Notice the color bleeding effect on the floor, the green curtain and the red cloth bled amazing colors on the floor, the wood floor also bled soft colors on the green curtain.

### TODO
Fix some issues.

### License
The MIT License (MIT)
