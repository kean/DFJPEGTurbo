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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DFJPEGRoundingMode) {
    /* Pick the closest scale. */
    DFJPEGRoundingModeNearest,
    /* Pick the closest scale that is greater than or equal to the input scale. */
    DFJPEGRoundingModeGreaterOrEqual,
    /* Pick the closest scale that is less than or equal to the input scale. */
    DFJPEGRoundingModeLessOrEqual
};

typedef struct {
    int numenator;
    int denominator;
} DFJPEGScale;

static inline DFJPEGScale
DFJPEGScaleMake(int numenator, int denominator) {
    return (DFJPEGScale){ .numenator = numenator, .denominator = denominator };
}

/*! Objective-C libjpeg-turbo wrapper.
 */
@interface DFJPEGTurboImageDecoder : NSObject

#pragma mark - Decompression

/*! Decompresses JPEG image data.
 @param data JPEG image data.
 @param orientation Output image orientation.
 @param scale Scale to be apply to the image during decompression.
 @warning Scale must be implemented by libjpeg-turbo which supports only several predefined scaling factors (1/1, 1/2, 1/4 etc). In other case the image is going to be cropped.
 */
+ (UIImage *)imageWithData:(NSData *)data
               orientation:(UIImageOrientation)orientation
                     scale:(DFJPEGScale)scale;

/*! Decompresses JPEG image data.
 @param data JPEG image data.
 @param orientation Output image orientation.
 @param scale Scale to be apply to the image during decompression.
 @param rounding libjpeg-turbo only supports several predefined scaling factors (1/1, 1/2, 1/4 etc). The rounding mode is a way to specify which one to pick if the input scale is not on the list.
 */
+ (UIImage *)imageWithData:(NSData *)data
               orientation:(UIImageOrientation)orientation
                     scale:(CGFloat)scale
                  rounding:(DFJPEGRoundingMode)rounding;

/*! Decompresses JPEG image data. Image orientation is retrieved from EXIF.
 @param data JPEG image data.
 */
+ (UIImage *)imageWithData:(NSData *)data;

/*! Decompresses JPEG image data.
 @param data JPEG image data.
 @param orientation Image orientation of image data.
 */
+ (UIImage *)imageWithData:(NSData *)data orientation:(UIImageOrientation)orientation;

#pragma mark - EXIF

/*! Returns image orientation from an EXIF associated with a given JPEG data.
 */
+ (UIImageOrientation)imageOrientationForData:(NSData *)data;

#pragma mark - Scaling Factors

/*! Returns the scaling factors closest to the input scale. libjpeg-turbo only supports several predefined scaling factors (1/1, 1/2, 1/4 etc).
 @param scale Scale to be apply to the image during decompression.
 @param rounding The rounding mode is a way to specify which predefined scaling factor to pick if the input scale is not on the list.
 */
+ (DFJPEGScale)scalingFactorForScale:(CGFloat)scale roundingMode:(DFJPEGRoundingMode)roundingMode;

/*! Returns the list of all scaling factors provided by libjpeg-turbo.
 @return pointer to a static C array.
 */
+ (DFJPEGScale *)scalingFactors:(NSUInteger *)count;

@end
