//
//  DFJPEGTurboTests.m
//  DFJPEGTurboTests
//
//  Created by Alexander Grebenyuk on 2/27/14.
//  Copyright (c) 2014 Alexander Grebenyuk. All rights reserved.
//

#import "DFJPEGTurbo.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>

@interface DFJPEGTurboTests : XCTestCase

@end

@implementation DFJPEGTurboTests

- (void)testDecompression {
    NSString *filePath = [[NSBundle bundleForClass:[self class] ] pathForResource:@"sample-01" ofType:@"jpeg"];
    NSData *data = [NSData dataWithContentsOfFile:filePath]; // 2048 x 1536
    
    UIImage *image = [DFJPEGTurbo imageWithData:data];
    XCTAssertTrue(image.size.width == 1024.f);
    XCTAssertTrue(image.size.height == 768.f);
}

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

@end
