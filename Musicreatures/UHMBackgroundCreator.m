//
//  UHMBackgroundCreator.m
//  Musicreatures
//
//  Created by Petri J Myllys on 05/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMBackgroundCreator.h"
#import "GPUImage.h"

static BOOL RESIZE_IMAGE = YES;
static BOOL FILTER_IMAGE = YES;

@interface UHMBackgroundCreator()

UIImage* forcePortraitOrientationForImage(UIImage* image);
UIImage* resizeImageKeepingAspectRatio(UIImage* image, CGSize newSize);

@end

@implementation UHMBackgroundCreator

+(UIImage*)createFilteredBackgroundImage:(UIImage*)image size:(CGSize)size {
    UIImage *newImage;
    
    if (RESIZE_IMAGE) {
        newImage = resizeImageKeepingAspectRatio(image, size);
    }
    
    else {
        newImage = image;
    }
    
    if (FILTER_IMAGE) {
        newImage = filterImage(newImage);
        return newImage;
    }
    
    else {
        return newImage;
    }
}

UIImage* forcePortraitOrientationForImage(UIImage* image) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:1.0
                         orientation:UIImageOrientationUp];
}

UIImage* resizeImageKeepingAspectRatio(UIImage* image, CGSize newSize) {
    float targetWidth = newSize.width;
    float targetHeight = newSize.height;
    
    float widthRatio = image.size.width / targetWidth;
    float heightRatio = image.size.height / targetHeight;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    targetWidth = image.size.width / divisor;
    targetHeight = image.size.height / divisor;
    
    CGRect drawRectangle = CGRectMake(0, 0, targetWidth, targetHeight);
    
    double imageShorterThanFrame = newSize.height - targetHeight;
    double imageNarrowerThanFrame = newSize.width - targetWidth;
    
    if (imageShorterThanFrame > 0)
        drawRectangle.origin.y = imageShorterThanFrame / 2.0;
    
    if (imageNarrowerThanFrame > 0)
        drawRectangle.origin.x = imageNarrowerThanFrame / 2.0;
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:drawRectangle];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resizedImage;
}

UIImage* filterImage(UIImage *image) {
    GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageContrastFilter *contrast = [[GPUImageContrastFilter alloc] init];
    GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
    GPUImageLevelsFilter *levels = [[GPUImageLevelsFilter alloc] init];
    GPUImageBilateralFilter *bilateral = [[GPUImageBilateralFilter alloc] init];
    GPUImageGaussianBlurFilter *blur = [[GPUImageGaussianBlurFilter alloc] init];
    
    contrast.contrast = 1.5;
    saturation.saturation = 1.5;
    [levels setMin:0.0
             gamma:1.0
               max:1.0
            minOut:0.1
            maxOut:0.9];
    bilateral.texelSpacingMultiplier = 2.0;
    bilateral.distanceNormalizationFactor = 1.5;
    blur.blurRadiusInPixels = 5;
    
    [source addTarget:contrast];
    [contrast addTarget:saturation];
    [contrast addTarget:levels];
    [levels addTarget:bilateral];
    [bilateral addTarget:blur];
    
    [blur useNextFrameForImageCapture];
    [source processImage];
    
    return [blur imageFromCurrentFramebuffer];
}

@end
