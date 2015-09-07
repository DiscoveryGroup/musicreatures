//
//  UHMPlayViewController.h
//  Musicreatures
//

//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "PdDispatcher.h"
#import "UHMCameraViewController.h"
#import "UHMAbstractPlayScene.h"
#import "UHMMenuScene.h"
#import "UHMHelpPopup.h"

@interface UHMPlayViewController : UIViewController <PdReceiverDelegate, UHMCameraViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) UHMAbstractPlayScene *playScene;
@property (strong, nonatomic) UHMMenuScene *menuScene;
@property (strong, nonatomic) UHMHelpPopup *helpPopup;

-(void)play;
-(void)startTutorial;
-(void)resetToMenu;
-(void)resetToCamera;
-(void)updatePulseIndex:(int)currentPulse forCreatureName:(NSString*)creatureName;

@end
