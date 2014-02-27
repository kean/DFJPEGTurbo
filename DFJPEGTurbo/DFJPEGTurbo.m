/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Alexander Grebenyuk (github.com/kean).
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "DFJPEGTurbo.h"
#import "turbojpeg.h"

static inline CGFloat
_dwarf_jpegturbo_aspect_fit_scale(CGSize imageSize, CGSize boundsSize) {
    CGFloat scaleWidth = boundsSize.width / imageSize.width;
    CGFloat scaleHeight = boundsSize.height / imageSize.height;
    return MIN(scaleWidth, scaleHeight);
}

static inline CGFloat
_dwarf_jpegturbo_aspect_fill_scale(CGSize imageSize, CGSize boundsSize) {
    CGFloat scaleWidth = boundsSize.width / imageSize.width;
    CGFloat scaleHeight = boundsSize.height / imageSize.height;
    return MAX(scaleWidth, scaleHeight);
}

static inline tjscalingfactor
_dwarf_best_scaling_factor(int width, int height, CGSize desiredSize, DFJPEGTurboScalingMode scaling, DFJPEGTurboRoundingMode rounding) {
    tjscalingfactor scalingFactor = { .num = 1, .denom = 1 };
    
    CGFloat scale; // Scaling factor that exactly matches bounds and scaling mode.
    CGSize imageSize = CGSizeMake(width, height);
    switch (scaling) {
        case DFJPEGTurboScalingModeAspectFit:
            scale = _dwarf_jpegturbo_aspect_fit_scale(imageSize, desiredSize);
            break;
        case DFJPEGTurboScalingModeAspectFill:
            scale = _dwarf_jpegturbo_aspect_fill_scale(imageSize, desiredSize);
            break;
        case DFJPEGTurboScalingModeNone:
        default:
            scale = 1.0;
            break;
    }
    
    if (scale >= 1.0) {
        return scalingFactor; // Scaling factor can't be greater than 1.0.
    }
    
    int desiredWidth = width * scale;
    int pickedWidth = width;
    
    // Compute best scaling factors for requirements.
    int num;
    tjscalingfactor *factors = tjGetScalingFactors(&num);
    for (int i = 0; i < num; i++) {
        tjscalingfactor factor = factors[i];
        int scaledWidth = TJSCALED(width, factor);
        int widthDiff = abs(desiredWidth - scaledWidth);
        int pickedWidthDiff = abs(desiredWidth - pickedWidth);
        
        if (widthDiff < pickedWidthDiff) {
            switch (rounding) {
                case DFJPEGTurboRoundingModeCeil:
                    if (scaledWidth >= desiredWidth) {
                        pickedWidth = scaledWidth;
                        scalingFactor = factor;
                    }
                    break;
                case DFJPEGTurboRoundingModeFloor:
                    if (scaledWidth <= desiredWidth) {
                        pickedWidth = scaledWidth;
                        scalingFactor = factor;
                    }
                    break;
                case DFJPEGTurboRoundingModeRound:
                    pickedWidth = scaledWidth;
                    scalingFactor = factor;
                    break;
                default:
                    break;
            }
        }
    }
    
    return scalingFactor;
}


@implementation DFJPEGTurbo

static void _dwarf_jpegturbo_release_data (void *info, const void *data, size_t size) {
    free(info);
}

#pragma mark - Decompression

+ (UIImage *)jpegImageWithData:(NSData *)data {
    return [self jpegImageWithData:data
                       orientation:UIImageOrientationUp
                       desiredSize:CGSizeZero
                           scaling:DFJPEGTurboScalingModeNone
                          rounding:0];
}

+ (UIImage *)jpegImageWithData:(NSData *)data
                   orientation:(UIImageOrientation)orientation {
    return [self jpegImageWithData:data
                       orientation:orientation
                       desiredSize:CGSizeZero
                           scaling:DFJPEGTurboScalingModeNone
                          rounding:0];
}

+ (UIImage *)jpegImageWithData:(NSData *)data
                   orientation:(UIImageOrientation)orientation
                   desiredSize:(CGSize)desiredSize
                       scaling:(DFJPEGTurboScalingMode)scaling
                      rounding:(DFJPEGTurboRoundingMode)rounding {
    if (!data) {
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
    
    if (scaling != DFJPEGTurboScalingModeNone) {
        tjscalingfactor factor = _dwarf_best_scaling_factor(width, height, desiredSize, scaling, rounding);
        width = TJSCALED(width, factor);
        height = TJSCALED(height, factor);
    }
    
    int pitch = width * 4;
    size_t capacity = height * pitch;
    unsigned char *imageData = calloc(capacity, sizeof(unsigned char));
    
    result = tjDecompress2(decoder, jpegBuf, jpegSize, imageData, width, pitch, height, TJPF_RGBA, 0);
    if (result < 0) {
        free(imageData);
        tjDestroy(decoder);
        return nil;
    }
    
    CGDataProviderRef imageDataProvider = CGDataProviderCreateWithData(imageData, imageData, capacity, &_dwarf_jpegturbo_release_data);
    
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

@end
