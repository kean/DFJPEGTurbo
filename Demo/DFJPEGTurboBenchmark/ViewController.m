//
//  ViewController.m
//  DFJPEGTurboBenchmark
//
//  Created by Alexander Grebenyuk on 3/10/14.
//  Copyright (c) 2014 Alexander Grebenyuk. All rights reserved.
//

#import "ViewController.h"
#import "DFBenchmark.h"
#import "DFImageProcessing.h"
#import "DFJPEGTurbo.h"
#import "AFInflatedImage.h"
#import "SDWebImageDecoder.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _testJPEGTurboPerformance];
}

- (void)_testJPEGTurboPerformance {
    NSString *filePath = [[NSBundle bundleForClass:[self class] ] pathForResource:@"sample-01" ofType:@"jpeg"]; // 2048 x 1536
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    NSArray *images = @[ [DFImageProcessing imageWithImage:image scaledToSize:DFSizeScaled(image.size, 0.5f)], image, [DFImageProcessing imageWithImage:image scaledToSize:DFSizeScaled(image.size, 2.f)]];
    for (UIImage *image in images) {
        [self _benchmarkWithImage:image compressionQuality:0.25f];
        [self _benchmarkWithImage:image compressionQuality:0.5f];
        [self _benchmarkWithImage:image compressionQuality:0.75f];
        [self _benchmarkWithImage:image compressionQuality:1.f];
    }
}

- (void)_benchmarkWithImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality {
    NSLog(@"---------------------------------------------------");
    NSLog(@"Benchmarking JPEG decompression with image size: (%f, %f), compression quality: (%f)", image.size.width * image.scale, image.size.height * image.scale, compressionQuality);
    NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
    NSLog(@"SDWebImageDecoder:");
    dwarf_benchmark(YES, ^{
        @autoreleasepool {
            UIImage *image = [UIImage imageWithData:data];
            __attribute__((unused)) UIImage *decodedImage = [UIImage decodedImageWithImage:image];
        }
    });
    NSLog(@"AFNetworking");
    dwarf_benchmark(YES, ^{
        @autoreleasepool {
            __attribute__((unused)) UIImage *decodedImage = AFInflatedImageFromResponseWithDataAtScale(nil, data, [UIScreen mainScreen].scale);
        }
    });
    NSLog(@"DFJPEGTurbo:");
    dwarf_benchmark(YES, ^{
        @autoreleasepool {
            __attribute__((unused)) UIImage *decodedImage = [DFJPEGTurbo imageWithData:data orientation:UIImageOrientationDown];
        }
    });
}

@end
