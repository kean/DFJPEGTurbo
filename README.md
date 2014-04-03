# About DFJPEGTurbo

Objective-C [libjpeg-turbo](http://libjpeg-turbo.virtualgl.org) wrapper (JPEG image codec that uses SIMD instructions (MMX, SSE2, NEON) to accelerate baseline JPEG compression and decompression on x86, x86-64, and ARM systems). `DFJPEGTurbo` uses `libjpeg-turbo` version 1.3.0.

# Warning

There are two issues with libjpeg-turbo on iOS:
1. It's doesn't support ARM64
2. It's has the same performance as CGContextDrawImage on new CPUs.

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

# Benchmark

### Apple A5X (armv7)

| Input Image | SDWebImage | AFNetworking | DFJPEGTurbo | Avg. Ratio |
| ----------- | ----------------- | ------------ | ----------- | ---------- |
| 2048x1536, 0.25 compression quality | 218.29 ms | 214.40 ms | 121.46 ms | 1.78 |
| 2048x1536, 0.50 compression quality | 234.74 ms | 238.26 ms | 134.55 ms | 1.75 |
| 2048x1536, 0.75 compression quality | 230.02 ms | 239.85 ms | 154.50 ms | 1.58 |

# Installation
Current version (0.2.0) can be installed via [Cocoapods](http://cocoapods.org).
```
pod 'DFJPEGTurbo', '~> 0.2'
```

# Contacts
[Alexander Grebenyuk](https://github.com/kean)

# License
DFJPEGTurbo is available under the MIT license. See the LICENSE file for more info.
