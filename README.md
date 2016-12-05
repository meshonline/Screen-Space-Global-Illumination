# Screen-Space-Global-Illumination
The idea is simple, gather light from every pixel as global illumination for every pixel in low resolution mode.

GI = lightColor * max(0, dot(lightNormal, lightToPixelNormal)) * max(0, dot(pixelNormal, pixelToLightNormal))

![SSGI Screenshot](http://www.mesh-online.net/ssgi-demo.jpg)

### License
The MIT License (MIT)
