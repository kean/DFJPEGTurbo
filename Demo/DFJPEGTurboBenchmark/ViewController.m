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
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath] scale:[UIScreen mainScreen].scale];
    NSArray *images =
    @[ [DFImageProcessing imageWithImage:image scaledToSize:DFSizeScaled(image.size, 0.1f)],
       [DFImageProcessing imageWithImage:image scaledToSize:DFSizeScaled(image.size, 0.25f)],
       [DFImageProcessing imageWithImage:image scaledToSize:DFSizeScaled(image.size, 0.5f)],
       image,
       [DFImageProcessing imageWithImage:image scaledToSize:DFSizeScaled(image.size, 1.25f)]];
    for (UIImage *image in images) {
        [self _benchmarkWithImage:image compressionQuality:0.3f];
        [self _benchmarkWithImage:image compressionQuality:0.5f];
        [self _benchmarkWithImage:image compressionQuality:0.6f];
        [self _benchmarkWithImage:image compressionQuality:0.8f];
    }
}

- (void)_benchmarkWithImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality {
    printf("-------------------------------------------------------\n");
    printf("Decoding JPEG with image size (%.0f, %.0f), compression quality: (%.2f)\n", image.size.width * image.scale, image.size.height * image.scale, compressionQuality);
    NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
    printf("SDWebImageDecoder: ");
    dwarf_benchmark(YES, ^{
        @autoreleasepool {
            UIImage *image = [UIImage imageWithData:data];
            __attribute__((unused)) UIImage *decodedImage = [UIImage decodedImageWithImage:image];
        }
    });
    printf("AFNetworking: ");
    dwarf_benchmark(YES, ^{
        @autoreleasepool {
            __attribute__((unused)) UIImage *decodedImage = AFInflatedImageFromResponseWithDataAtScale(nil, data, [UIScreen mainScreen].scale);
        }
    });
    printf("DFJPEGTurbo: ");
    dwarf_benchmark(YES, ^{
        @autoreleasepool {
            __attribute__((unused)) UIImage *decodedImage = [DFJPEGTurbo imageWithData:data orientation:UIImageOrientationDown];
        }
    });
}

@end
