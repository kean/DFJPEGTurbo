//
//  AFInflatedImage.h
//  DFJPEGTurboBenchmark
//
//  Created by Alexander Grebenyuk on 3/11/14.
//  Copyright (c) 2014 Alexander Grebenyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static UIImage * AFImageWithDataAtScale(NSData *data, CGFloat scale) {
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    return [[UIImage alloc] initWithCGImage:[image CGImage] scale:scale orientation:image.imageOrientation];
}

static UIImage * AFInflatedImageFromResponseWithDataAtScale(NSHTTPURLResponse *response, NSData *data, CGFloat scale) {
    if (!data || [data length] == 0) {
        return nil;
    }
    
    CGImageRef imageRef = NULL;
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    /*!
    if ([response.MIMEType isEqualToString:@"image/png"]) {
        imageRef = CGImageCreateWithPNGDataProvider(dataProvider,  NULL, true, kCGRenderingIntentDefault);
    } else if ([response.MIMEType isEqualToString:@"image/jpeg"]) {
        imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
        
        // CGImageCreateWithJPEGDataProvider does not properly handle CMKY, so if so, fall back to AFImageWithDataAtScale
        if (imageRef) {
            CGColorSpaceRef imageColorSpace = CGImageGetColorSpace(imageRef);
            CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(imageColorSpace);
            if (imageColorSpaceModel == kCGColorSpaceModelCMYK) {
                CGImageRelease(imageRef);
                imageRef = NULL;
            }
        }
    } */
    
    // Hardcode jpeg data provider
    imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage *image = nil;
    if (!imageRef) {
        image = AFImageWithDataAtScale(data, scale);
        if (image.images || !image) {
            return image;
        }
        
        imageRef = CGImageCreateCopy([image CGImage]);
        if (!imageRef) {
            return nil;
        }
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    
    // Always inflate images
//    if (width * height > 1024 * 1024 || bitsPerComponent > 8) {
//        if (!image) {
//            image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:image.imageOrientation];
//        }
//        
//        CGImageRelease(imageRef);
//        
//        return image;
//    }
    
    size_t bytesPerRow = 0; // CGImageGetBytesPerRow() calculates incorrectly in iOS 5.0, so defer to CGBitmapContextCreate
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    if (colorSpaceModel == kCGColorSpaceModelRGB) {
        uint32_t alpha = (bitmapInfo & kCGBitmapAlphaInfoMask);
        if (alpha == kCGImageAlphaNone) {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaNoneSkipFirst;
        } else if (!(alpha == kCGImageAlphaNoneSkipFirst || alpha == kCGImageAlphaNoneSkipLast)) {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaPremultipliedFirst;
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        if (!image) {
            image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:image.imageOrientation];
        }
        
        CGImageRelease(imageRef);
        
        return image;
    }
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), imageRef);
    CGImageRef inflatedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *inflatedImage = [[UIImage alloc] initWithCGImage:inflatedImageRef scale:scale orientation:image.imageOrientation];
    
    CGImageRelease(inflatedImageRef);
    CGImageRelease(imageRef);
    
    return inflatedImage;
}
