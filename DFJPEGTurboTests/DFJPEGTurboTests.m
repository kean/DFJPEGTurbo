//
//  DFJPEGTurboTests.m
//  DFJPEGTurboTests
//
//  Created by Alexander Grebenyuk on 2/27/14.
//  Copyright (c) 2014 Alexander Grebenyuk. All rights reserved.
//

#import "DFBenchmark.h"
#import "DFImageProcessing.h"
#import "DFJPEGTurbo.h"
#import "SDWebImageDecoder.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface DFJPEGTurboTests : XCTestCase

@end

@implementation DFJPEGTurboTests

- (void)testPerformance {
    NSString * filePath = [[NSBundle bundleForClass:[self class] ] pathForResource:@"sample-01" ofType:@"jpeg"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    NSArray *images = @[ [DFImageProcessing imageWithImage:image scaledToSize:DFSizeScaled(image.size, 0.5f)], image, [DFImageProcessing imageWithImage:image scaledToSize:DFSizeScaled(image.size, 2.f)]];
    for (UIImage *image in images) {
        [self _benchmarkWithImage:image compressionQuality:0.33f];
        [self _benchmarkWithImage:image compressionQuality:0.66f];
        [self _benchmarkWithImage:image compressionQuality:1.f];
    }
}

- (void)_benchmarkWithImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality {
    NSLog(@"---------------------------------------------------");
    NSLog(@"Benchmarking jpeg decompression with image size: (%f, %f), compression quality: (%f)", image.size.width, image.size.height, compressionQuality);
    NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
    NSLog(@"Benchmark: SDWebImageDecoder");
    dwarf_benchmark(YES, ^{
        @autoreleasepool {
            UIImage *image = [UIImage imageWithData:data];
            __attribute__((unused)) UIImage *decodedImage = [UIImage decodedImageWithImage:image];
        }
    });
    NSLog(@"Benchmark: DFJPEGTurbo");
    dwarf_benchmark(YES, ^{
        @autoreleasepool {
            __attribute__((unused)) UIImage *decodedImage = [DFJPEGTurbo jpegImageWithData:data orientation:UIImageOrientationDown];
        }
    });
}

@end
