# About DFJPEGTurbo

Objective-C [libjpeg-turbo](http://libjpeg-turbo.virtualgl.org) wrapper (JPEG image codec that uses SIMD instructions (MMX, SSE2, NEON) to accelerate baseline JPEG compression and decompression on x86, x86-64, and ARM systems). `DFJPEGTurbo` uses `libjpeg-turbo` version 1.3.0.

### Requirements
- iOS 6.0

# Examples

#### Decompressing JPEG data
```objective-c
NSData *jpegData;
UIImage *image = [DFJPEGTurbo imageWithData:data];
```

#### Decompressing JPEG data with one of the libjpeg-turbo scale factors
```objective-c
NSData *jpegData;
// Scale must be implemented by libjpeg-turbon which supports only several scaling factors (1/1, 1/2, 1/4 etc).
// In other case the image is going to be cropped.
DFJPEGScale scale = DFJPEGScaleMake(1, 2); // 0.5 scale
UIImage *image = [DFJPEGTurbo imageWithData:jpegData orientation:UIImageOrientationDown scale:scale];
```

# Installation
Current version (0.2.0) can be installed via [Cocoapods](http://cocoapods.org).
```
pod 'DFJPEGTurbo', '~> 0.2'
```

# Contacts
[Alexander Grebenyuk](https://github.com/kean)

# License
DFJPEGTurbo is available under the MIT license. See the LICENSE file for more info.
