//
//  UHMCameraViewController.m
//  Musicreatures
//
//  Created by Petri J Myllys on 02/10/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"
#import "UHMAudioController.h"
#import "UHMCameraFocusIndicator.h"
#import "UHMHelpPopup.h"
#import "UHMActivityIndicator.h"

@interface UHMCameraViewController()

@property (strong, nonatomic) AVCaptureDevice *camera;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) UIView *captureFrame;
@property (strong, nonatomic) AVCaptureStillImageOutput *imageOutput;
@property (strong, nonatomic) UIButton *captureButton;
@property (strong, nonatomic) UHMCameraFocusIndicator *focusIndicator;
@property (strong, nonatomic) UHMHelpPopup *helpPopup;
@property (strong, nonatomic) UHMActivityIndicator *activityIndicator;

@end

@implementation UHMCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

-(void)loadView {
    CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
    UIView *mainView = [[UIView alloc] initWithFrame:mainScreenFrame];
    mainView.autoresizingMask = UIViewAutoresizingNone;
    
    self.view = mainView;
    
    self.captureFrame = [[UIView alloc] initWithFrame:CGRectMake((1.0f - CAMERA_FRAME_SIZE_MULTIPLIER) / 2 * self.view.frame.size.width,
                                                                 (1.0f - CAMERA_FRAME_SIZE_MULTIPLIER) / 2 * self.view.frame.size.height,
                                                                 self.view.frame.size.width * CAMERA_FRAME_SIZE_MULTIPLIER,
                                                                 self.view.frame.size.height * CAMERA_FRAME_SIZE_MULTIPLIER)];
    
    [self.view addSubview:self.captureFrame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.captureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 37.5f,
                                                                    self.view.frame.size.height,
                                                                    75.0f,
                                                                    75.0f)];
    
    [self.captureButton setImage:[UIImage imageNamed:@"shutterbutton.png"] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureButton];
    
    self.focusIndicator = [[UHMCameraFocusIndicator alloc] initWithFrame:self.view.frame];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
     self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    self.camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&error];
    
    [self.camera addObserver:self.focusIndicator forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:NULL];
    [self.view addSubview:self.focusIndicator];
    
    if ([self.captureSession canAddInput:deviceInput]) [self.captureSession addInput:deviceInput];
    
    AVCaptureVideoPreviewLayer *viewFinderLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [viewFinderLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = self.view.layer;
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.captureFrame.frame;
    
    [viewFinderLayer setFrame:frame];
    
    [rootLayer insertSublayer:viewFinderLayer atIndex:0];
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.imageOutput setOutputSettings:outputSettings];
    
    [self.captureSession addOutput:self.imageOutput];
    [self.captureSession startRunning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
        
    [(SKView*)viewController.view presentScene:viewController.playScene];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.captureButton.center = CGPointMake(self.captureButton.center.x, self.captureButton.center.y - 100.0f);}
                     completion:NULL
     ];
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenCameraHelp"]) return;
    
    self.helpPopup = [[UHMHelpPopup alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    self.view.frame.size.width,
                                                                    0.0f)
                                          containerFrame:self.view.frame
                                                helpText:NSLocalizedString(@"CameraHelp", nil)
                                          helpIdentifier:CAMERA_HELP];
    
    [self.view addSubview:self.helpPopup];
    self.helpPopup.hidden = NO;
}

-(void)takePhoto {
    [self configureUserInterfaceForAdvancing];
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in self.imageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) break;
    }
    
    if ([videoConnection isVideoOrientationSupported]) videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;

    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            [self.captureSession stopRunning];
            
            if([self.imageDelegate respondsToSelector:@selector(didCaptureImage:withError:)])
            {
                [self.imageDelegate didCaptureImage:image withError:error];
                [[UHMAudioController sharedAudioController] setGlobalPlaybackState:YES];
                
                [self.activityIndicator finishActivityIndicationWithCompletion:^{
                    [self.activityIndicator removeFromSuperview];
                    [self dismissViewControllerAnimated:YES completion:^{
                        if([self.imageDelegate respondsToSelector:@selector(didFinishCapturing)])
                            [self.imageDelegate didFinishCapturing];
                    }];
                }];
            }
            
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                message:@"Something unexpected happened while taking your photo."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                [alert show];
            }
        }
    }];
    
    self.activityIndicator = [[UHMActivityIndicator alloc] initWithTextColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.75f]
                                                                      shadow:YES
                                                                        font:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22]
                                                                        text:NSLocalizedString(@"Preparing your photo", nil)];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.alpha = 0.0;
    [self.view addSubview:self.activityIndicator];
    [UIView animateWithDuration:1.0 animations:^{
        self.activityIndicator.alpha = 1.0;
    } completion:nil];
}

-(void)configureUserInterfaceForAdvancing {
    [self.helpPopup remove];
    self.captureButton.userInteractionEnabled = NO;

    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.captureButton.frame = CGRectMake(CGRectGetMidX(self.captureButton.frame) - 0.4 * self.captureButton.frame.size.width,
                                                               CGRectGetMidY(self.captureButton.frame) - 0.4 * self.captureButton.frame.size.height,
                                                               0.8 * self.captureButton.frame.size.width,
                                                               0.8 * self.captureButton.frame.size.height);
                         self.captureButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.captureButton removeFromSuperview];
                     }
     ];

    
    [self.camera removeObserver:self.focusIndicator forKeyPath:@"adjustingFocus"];
    [self.focusIndicator removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
