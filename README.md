<h1 align="center">DFJPEGTurbo</h1>

<p align="center">
<a href="https://cocoapods.org/pods/DFJPEGTurbo"><img src="http://img.shields.io/cocoapods/v/DFJPEGTurbo.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
</p>

Objective-C [libjpeg-turbo](http://www.libjpeg-turbo.org) wrapper (JPEG image codec that uses SIMD instructions (MMX, SSE2, NEON) to accelerate baseline JPEG compression and decompression on x86, x86-64, and ARM systems). `DFJPEGTurbo` uses `libjpeg-turbo` version 1.4.1, which now includes arm64 support.

`DFJPEGTurbo` supports decompression of both baseline and **progressive** JPEG.

## Requirements
- iOS 6.0

## Examples

#### Decompressing JPEG
```objective-c
NSData *jpegData;
UIImage *image = [DFJPEGTurboImageDecoder imageWithData:data];
```

#### Decompressing JPEG with one of the libjpeg-turbo scale factors
```objective-c
NSData *jpegData;
// Scale must be implemented by libjpeg-turbo which supports only several scaling factors (1/1, 1/2, 1/4 etc).
DFJPEGScale scale = DFJPEGScaleMake(1, 2); // 0.5 scale
UIImage *image = [DFJPEGTurboImageDecoder imageWithData:jpegData orientation:UIImageOrientationDown scale:scale];
```

## Benchmark (Baseline JPEG)

Benchmark on older ARM-based systems (iPhone 4S, iPhone 5C) shows that libjpeg-turbo provides a very noticable performance boost over native CGContextDrawImage. However, libjpeg-turbo underperforms on newer systems (iPhone 6). For benchmark implementation see Demo/DFJPEGTurboBenchmark in a project folder.

### iPhone 6 (Apple A8)

| Input Image | CGContextDrawImage | libjpeg-turbo |
| ----------- | ------------------ | ------------- |
| 1024x768, 0.3 compression quality | 10.51 ms | 9.75 ms |
| 1024x768, 0.5 compression quality | 10.56 ms | 10.15 ms |
| 1024x768, 0.7 compression quality | 10.14 ms | 11.61 ms |
| 1024x768, 0.9 compression quality | 10.13 ms | 12.44 ms |
| 2048x1536, 0.3 compression quality | 41.60 ms | 36.98 ms |
| 2048x1536, 0.5 compression quality | 33.46 ms | 40.56 ms |
| 2048x1536, 0.7 compression quality | 33.85 ms | 45.53 ms |
| 2048x1536, 0.9 compression quality | 34.79 ms | 52.60 ms |

### iPhone 5C (Apple A6)

| Input Image | CGContextDrawImage | DFJPEGTurbo |
| ----------- | ------------------ | ----------- |
| 1024x768, 0.3 compression quality | 42.47 ms | 22.26 ms |
| 1024x768, 0.5 compression quality | 40.75 ms | 23.28 ms |
| 1024x768, 0.7 compression quality | 40.51 ms | 26.11 ms |
| 1024x768, 0.9 compression quality | 39.82 ms | 29.77 ms |
| 2048x1536, 0.3 compression quality | 130.72 ms | 81.95 ms |
| 2048x1536, 0.5 compression quality | 129.83 ms | 86.50 ms |
| 2048x1536, 0.7 compression quality | 130.42 ms | 98.17 ms |
| 2048x1536, 0.9 compression quality | 130.03 ms | 106.18 ms |

## Installation using CocoaPods

To install DFJPEGTurbo add a dependency in your [Podfile](http://cocoapods.org).
```
pod 'DFJPEGTurbo'
```

## Contacts

<a href="https://github.com/kean">
<img src="https://cloud.githubusercontent.com/assets/1567433/6521218/9c7e2502-c378-11e4-9431-c7255cf39577.png" height="44" hspace="2"/>
</a>
<a href="https://twitter.com/a_grebenyuk">
<img src="https://cloud.githubusercontent.com/assets/1567433/6521243/fb085da4-c378-11e4-973e-1eeeac4b5ba5.png" height="44" hspace="2"/>
</a>
<a href="https://www.linkedin.com/pub/alexander-grebenyuk/83/b43/3a0">
<img src="https://cloud.githubusercontent.com/assets/1567433/6521256/20247bc2-c379-11e4-8e9e-417123debb8c.png" height="44" hspace="2"/>
</a>

## License

DFJPEGTurbo is available under the MIT license. See the LICENSE file for more info.
