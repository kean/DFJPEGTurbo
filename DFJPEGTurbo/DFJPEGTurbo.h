/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Alexander Grebenyuk (github.com/kean).
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

typedef NS_ENUM(NSUInteger, DFJPEGTurboScalingMode) {
    DFJPEGTurboScalingModeNone,       // Do not scale
    DFJPEGTurboScalingModeAspectFit,  // Scale image to fit size
    DFJPEGTurboScalingModeAspectFill  // Scale image to fill size
};

typedef NS_ENUM(NSUInteger, DFJPEGTurboRoundingMode) {
    /*! Scaled image width >= desired image width. */
    DFJPEGTurboRoundingModeFloor,
    /*! Scaled image width <= desired image width. */
    DFJPEGTurboRoundingModeCeil,
    /*! Scaled image width is as close to the desired size as possible. */
    DFJPEGTurboRoundingModeRound
};

/*! Objective-C libjpeg-turbo wrapper.
 */
@interface DFJPEGTurbo : NSObject

#pragma mark - Decompression

/*! Decompresses JPEG image data. Returns nil if input data is not in JPEG format.
 @param data JPEG image data.
 @param orientation Image orientation of image data.
 @param desiredSize Desired image size. Original image is returned if desired size is CGSizeZero.
 @discussion Scaling: libjpeg-turbo supports several scaling factors (0.5, 0.25, 0.125 etc). There is no way to get image the exact disired size you want. There are multiple options (scaling & rounding) to define the algorithm to pick scaling factor.
 */
+ (UIImage *)jpegImageWithData:(NSData *)data
                   orientation:(UIImageOrientation)orientation
                   desiredSize:(CGSize)desiredSize
                       scaling:(DFJPEGTurboScalingMode)scaling
                      rounding:(DFJPEGTurboRoundingMode)rounding;

+ (UIImage *)jpegImageWithData:(NSData *)data;
+ (UIImage *)jpegImageWithData:(NSData *)data orientation:(UIImageOrientation)orientation;

@end
