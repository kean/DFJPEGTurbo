// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DFJPEGTurboImageDecoder.h"
#import "turbojpeg.h"
#import <ImageIO/ImageIO.h>

static void
_dwarf_jpeg_release_data(void *info, const void *data, size_t size) {
    free(info);
}

static inline DFJPEGScale
_dwarf_scaling_factor_to_scale(tjscalingfactor factor) {
    return (DFJPEGScale){ .numenator = factor.num, .denominator = factor.denom };
}

static inline CGFloat
_scale_for_factor(DFJPEGScale factor) {
    return factor.numenator / ((CGFloat)factor.denominator);
}

@implementation DFJPEGTurboImageDecoder

#pragma mark - Decompression

+ (UIImage *)imageWithData:(NSData *)data {
    UIImageOrientation orientation = [self imageOrientationForData:data];
    return [self imageWithData:data orientation:orientation];
}

+ (UIImage *)imageWithData:(NSData *)data orientation:(UIImageOrientation)orientation {
    return [self imageWithData:data orientation:orientation scale:1.f rounding:0];
}

+ (UIImage *)imageWithData:(NSData *)data
               orientation:(UIImageOrientation)orientation
                     scale:(CGFloat)scale
                  rounding:(DFJPEGRoundingMode)rounding {
    DFJPEGScale jpegScale = [self scalingFactorForScale:scale roundingMode:rounding];
    return [self imageWithData:data orientation:orientation scale:jpegScale];
}

+ (UIImage *)imageWithData:(NSData *)data
               orientation:(UIImageOrientation)orientation
                     scale:(DFJPEGScale)scale {
    if (!data.length) {
        return nil;
    }
    
    tjhandle decoder = tjInitDecompress();
    
    unsigned char *jpegBuf = (unsigned char *)data.bytes;
    unsigned long jpegSize = data.length;
    int width, height, jpegSubsamp;
    
    int result = tjDecompressHeader2(decoder, jpegBuf, jpegSize, &width, &height, &jpegSubsamp);
    if (result < 0) {
        tjDestroy(decoder);
        return nil;
    }
    
    tjscalingfactor tjfactor = (tjscalingfactor){ .num = (int)scale.numenator, .denom = (int)scale.denominator };
    width = TJSCALED(width, tjfactor);
    height = TJSCALED(height, tjfactor);
    
    int pitch = width * 4;
    size_t capacity = height * pitch;
    unsigned char *imageData = calloc(capacity, sizeof(unsigned char));
    
    result = tjDecompress2(decoder, jpegBuf, jpegSize, imageData, width, pitch, height, TJPF_RGBA, 0);
    if (result < 0) {
        free(imageData);
        tjDestroy(decoder);
        return nil;
    }
    
    CGDataProviderRef imageDataProvider = CGDataProviderCreateWithData(imageData, imageData, capacity, &_dwarf_jpeg_release_data);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef image = CGImageCreate(width, height, 8, 32, pitch, colorspace, kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast, imageDataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:orientation];
    
    if (image) {
        CGImageRelease(image);
    }
    CGDataProviderRelease(imageDataProvider);
    CGColorSpaceRelease(colorspace);
    tjDestroy(decoder);
    
    return decompressedImage;
}

#pragma mark - EXIF

+ (UIImageOrientation)imageOrientationForData:(NSData *)data {
    UIImageOrientation orientation = UIImageOrientationUp;
    if (!data.length) {
        return UIImageOrientationUp;
    }
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    if (imageSourceRef) {
        CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        if (dictRef) {
            NSNumber *exifOrientation = (__bridge NSNumber *) CFDictionaryGetValue(dictRef, kCGImagePropertyOrientation);
            orientation = [self _imageOrientationForExifOrientation:exifOrientation.intValue];
            CFRelease(dictRef);
        }
        CFRelease(imageSourceRef);
    }
    return orientation;
}

+ (UIImageOrientation)_imageOrientationForExifOrientation:(int)exifOrientation {
    switch (exifOrientation) {
        case 1: return UIImageOrientationUp;
        case 2: return UIImageOrientationUpMirrored;
        case 3: return UIImageOrientationDown;
        case 4: return UIImageOrientationDownMirrored;
        case 5: return UIImageOrientationLeftMirrored;
        case 6: return UIImageOrientationRight;
        case 7: return UIImageOrientationRightMirrored;
        case 8: return UIImageOrientationLeft;
        default: return UIImageOrientationUp;
    }
}

#pragma mark - Scaling Factors

+ (DFJPEGScale)scalingFactorForScale:(CGFloat)scale roundingMode:(DFJPEGRoundingMode)roundingMode {
    NSAssert(scale >= 0.f, @"Scale must be positive");
    if (scale < 0.f || scale >= 1.f) {
        return DFJPEGScaleMake(1, 1);
    }
    NSUInteger count;
    DFJPEGScale *factors = [self scalingFactors:&count];
    DFJPEGScale outFactor = DFJPEGScaleMake(1, 1);
    for (int i = 0; i < count; i++) {
        DFJPEGScale factor = factors[i];
        CGFloat factorScale = _scale_for_factor(factor);
        if (fabs(scale - factorScale) >=
            fabs(scale - _scale_for_factor(outFactor))) {
            continue;
        }
        switch (roundingMode) {
            case DFJPEGRoundingModeLessOrEqual:
                if (factorScale <= scale) {
                    outFactor = factor;
                }
                break;
            case DFJPEGRoundingModeGreaterOrEqual:
                if (factorScale >= scale) {
                    outFactor = factor;
                }
                break;
            case DFJPEGRoundingModeNearest:
                outFactor = factor;
                break;
            default:
                break;
        }
    }
    return outFactor;
}

+ (DFJPEGScale *)scalingFactors:(NSUInteger *)count {
    static DFJPEGScale *_factors;
    static NSUInteger _count;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        int count;
        tjscalingfactor *factors = tjGetScalingFactors(&count);
        _factors = calloc(sizeof(DFJPEGScale), count);
        for (int i = 0; i < count; i++) {
            tjscalingfactor factor = factors[i];
            _factors[i] = _dwarf_scaling_factor_to_scale(factor);
        }
        _count = count;
    });
    if (count) {
        *count = _count;
    }
    return _factors;
}

@end
