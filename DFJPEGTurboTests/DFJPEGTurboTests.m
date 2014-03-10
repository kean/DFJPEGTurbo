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
#import <objc/runtime.h>

@interface DFJPEGTurboTests : XCTestCase

@end

@implementation DFJPEGTurboTests

- (DFJPEGScale *)_mockedScalingFactors:(NSUInteger *)count {
    static DFJPEGScale *factors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factors = calloc(sizeof(DFJPEGScale), 4);
        factors[0] = DFJPEGScaleMake(1, 1);
        factors[1] = DFJPEGScaleMake(1, 2);
        factors[2] = DFJPEGScaleMake(1, 4);
        factors[3] = DFJPEGScaleMake(1, 8);
    });
    if (count) {
        *count = 4;
    }
    return factors;
}

- (void)testScalingFactors {
    Method originalImpl = class_getClassMethod([DFJPEGTurbo class], @selector(scalingFactors:));
    Method mockImpl = class_getInstanceMethod([self class], @selector(_mockedScalingFactors:));
    method_exchangeImplementations(originalImpl, mockImpl);

    {
        DFJPEGScale scale = [DFJPEGTurbo scalingFactorForScale:0.25f roundingMode:DFJPEGRoundingModeNearest];
        XCTAssertTrue(scale.numenator == 1 && scale.denominator == 4);
    }
    
    {
        DFJPEGScale scale = [DFJPEGTurbo scalingFactorForScale:0.25f roundingMode:DFJPEGRoundingModeGreaterOrEqual];
        XCTAssertTrue(scale.numenator == 1 && scale.denominator == 4);
    }
    
    {
        DFJPEGScale scale = [DFJPEGTurbo scalingFactorForScale:0.25f roundingMode:DFJPEGRoundingModeLessOrEqual];
        XCTAssertTrue(scale.numenator == 1 && scale.denominator == 4);
    }
    
    {
        DFJPEGScale scale = [DFJPEGTurbo scalingFactorForScale:0.22f roundingMode:DFJPEGRoundingModeNearest];
        XCTAssertTrue(scale.numenator == 1 && scale.denominator == 4);
    }
    
    {
        DFJPEGScale scale = [DFJPEGTurbo scalingFactorForScale:0.22f roundingMode:DFJPEGRoundingModeGreaterOrEqual];
        XCTAssertTrue(scale.numenator == 1 && scale.denominator == 4);
    }
    
    {
        DFJPEGScale scale = [DFJPEGTurbo scalingFactorForScale:0.22f roundingMode:DFJPEGRoundingModeLessOrEqual];
        XCTAssertTrue(scale.numenator == 1 && scale.denominator == 8);
    }
    
    method_exchangeImplementations(originalImpl, mockImpl);
}

- (void)testScaling_0_5 {
    NSString *filePath = [[NSBundle bundleForClass:[self class] ] pathForResource:@"sample-01" ofType:@"jpeg"];
    NSData *data = [NSData dataWithContentsOfFile:filePath]; // 2048 x 1536
    
    UIImage *image = [DFJPEGTurbo imageWithData:data orientation:UIImageOrientationDown scale:0.5f rounding:DFJPEGRoundingModeNearest];
    XCTAssertTrue(image.size.width == 512.f);
    XCTAssertTrue(image.size.height == 384.f);
}

- (void)testPerformance {
    NSString *filePath = [[NSBundle bundleForClass:[self class] ] pathForResource:@"sample-01" ofType:@"jpeg"];
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
            __attribute__((unused)) UIImage *decodedImage = [DFJPEGTurbo imageWithData:data orientation:UIImageOrientationDown];
        }
    });
}

@end
