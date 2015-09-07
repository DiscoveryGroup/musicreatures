//
//  UHMCameraViewController.h
//  Musicreatures
//
//  Created by Petri J Myllys on 02/10/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CAMERA_FRAME_SIZE_MULTIPLIER 1.125f

@protocol UHMCameraViewControllerDelegate

-(void)didCaptureImage:(UIImage*)image withError:(NSError*)error;
-(void)didFinishCapturing;

@end

@interface UHMCameraViewController : UIViewController

@property(weak, nonatomic) id imageDelegate;

@end
