//
//  UHMHelpPopup.h
//  Musicreatures
//
//  Created by Petri J Myllys on 01/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UHMShadowedLabel.h"

typedef enum {
    CREATE_GROUP_HELP,
    CREATE_MORE_GROUPS_HELP,
    MOVING_HELP,
    COLOR_HELP,
    SCATTER_HELP,
    PULSE_HELP,
    REST_HELP,
    IMPROVISATION_HELP,
    IMPROVISATION_GESTURES_HELP,
    LIFESPAN_HELP,
    READY_HELP,
    CAMERA_HELP
} HelpIdentifier;

@interface UHMHelpPopup : UIView

@property (strong, nonatomic, readonly) UHMShadowedLabel *info;
@property (nonatomic) HelpIdentifier identifier;
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL allowToBeDismissed;
@property (strong, nonatomic) NSString *buttonTitle;
@property (nonatomic) CGFloat buttonWidth;
@property (nonatomic) CGFloat verticalOffset;
@property (nonatomic) BOOL useFade;

-(id)initWithFrame:(CGRect)frame containerFrame:(CGRect)container helpText:(NSString*)text helpIdentifier:(HelpIdentifier)identifier;
-(void)replaceTextWithString:(NSString*)text;
-(void)remove;

@end
