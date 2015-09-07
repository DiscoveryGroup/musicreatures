//
//  UHMMotionController.m
//  Musicalizer
//
//  Created by Petri J Myllys on 06/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMMotionController.h"
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"
#import "UHMLowPassFilter.h"
#import "UHMAudioController.h"

double synthGainEnvelopeTransferFunction(double input);
double synthFilterCutoffTransferFunction(double input);

@interface UHMMotionController ()

@property (nonatomic) BOOL active;

@property (strong, nonatomic) NSMutableDictionary *filters;

@end

static UHMMotionController *sharedMotionController = nil;

@implementation UHMMotionController {
    NSTimer *_timer;
}

+(id)sharedMotionController {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMotionController = [[self alloc] init];
    });
    
    return sharedMotionController;
}

-(id)init {
    self = [super init];
    
    if (self) {
        if ([self isDeviceMotionAvailable]) {
            [self setDeviceMotionUpdateInterval:0.01];
        }
        
        [self registerFilters];
    }
    
    return self;
}

-(void)registerFilters {
    self.filters = [[NSMutableDictionary alloc] init];
    [self.filters setValue:[[UHMLowPassFilter alloc] init] forKey:@"pitch"];
    [self.filters setValue:[[UHMLowPassFilter alloc] init] forKey:@"roll"];
    [self.filters setValue:[[UHMLowPassFilter alloc] init] forKey:@"magnitude"];
}

-(void)setActive:(BOOL)active {
    _active = active;
    
    if (_active) {
        [self startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
        
        if (!_timer && [self isDeviceMotionAvailable]) {
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                             target:self
                                           selector:@selector(getValues:)
                                           userInfo:nil
                                            repeats:YES];
        }

    } else {
        [self stopDeviceMotionUpdates];
        
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        
        _timer = nil;
    }
}

-(void)getValues:(NSTimer*)timer {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    [self updateRestrictedRoll];
    [self updateSmoothedAttitude];
    
    double acceleration = sqrt(pow(self.deviceMotion.userAcceleration.x, 2) +
                               pow(self.deviceMotion.userAcceleration.y, 2) +
                               pow(self.deviceMotion.userAcceleration.z, 2));
    
    double filteredAcceleration = [self filterMeasurement:acceleration
                                               withFilter:[self.filters valueForKey:@"magnitude"]
                                                smoothing:0.1];
    
    self.accelerationMagnitude = filteredAcceleration;
    
    if (viewController.playScene.solo) {
        
        viewController.playScene.harmony.intensity = self.accelerationMagnitude / 3.0;
        
        [[UHMAudioController sharedAudioController] setSynthModulationIntensity:filteredAcceleration * 1000.0f];
        
        float maxSynthGain = filteredAcceleration;
        maxSynthGain = maxSynthGain > 1.0f ? maxSynthGain = 1.0f : maxSynthGain;
        maxSynthGain = maxSynthGain < 0.0f ? maxSynthGain = 0.0f : maxSynthGain;
        
        float s1 = synthGainEnvelopeTransferFunction(acceleration);
        float s2 = s1 * 2.0;
        float s3 = s2 * 5.0;
        float s4 = s1 * 30.0;
        NSArray *synthGainEnvelope = @[@(maxSynthGain), @(s1),
                                     @(0.8 * maxSynthGain), @(s2), @(s1),
                                     @(0.2 * maxSynthGain), @(s3), @(s1 + 2.0 * s2),
                                     @0, @(s4), @(s1 + 2.0 * s2 + s3)];
        
        [[UHMAudioController sharedAudioController] setSynthGainEnvelope:synthGainEnvelope];
        [[UHMAudioController sharedAudioController] setSynthFilterCutoffFrequency:synthFilterCutoffTransferFunction((filteredAcceleration + acceleration) / 2.0)];
        
        float maxBassFilterFrequency = filteredAcceleration * 5000;
        maxBassFilterFrequency = maxBassFilterFrequency > 20000.0f ? maxBassFilterFrequency = 20000.0f : maxBassFilterFrequency;
        maxBassFilterFrequency = maxBassFilterFrequency < 1000.0f ? maxBassFilterFrequency = 1000.0f : maxBassFilterFrequency;
        
        float b1 = filteredAcceleration * 3.0;
        float b2 = b1;
        float b3 = b2;
        float b4 = b3 * 15.0;
        NSArray *bassFilterEnvelope = @[@(maxBassFilterFrequency), @(b1),
                                        @(0.85 * maxBassFilterFrequency), @(b2), @(b1),
                                        @(0.6 * maxBassFilterFrequency), @(b3), @(b1 + b2),
                                        @(0.2 * maxBassFilterFrequency), @(b4), @(b1 + b2 + b3)];
        
        [[UHMAudioController sharedAudioController] setBassFilterEnvelope:bassFilterEnvelope];
        [[UHMAudioController sharedAudioController] setKickFilterCutoffFrequency:kickFilterCutoffTransferFunction(filteredAcceleration)];
        
        [[UHMAudioController sharedAudioController] setMainGain:filteredAcceleration * 0.6 + 0.6];
        
        
        static BOOL kick = YES;
        static BOOL hat = YES;
        
        if (kick && self.deviceMotion.userAcceleration.z > 1.0) {
            [[UHMAudioController sharedAudioController] playSnare];
            kick = NO;
        }
        
        if (hat && self.deviceMotion.userAcceleration.x > 1.6 && self.deviceMotion.userAcceleration.z < 0.6) {
            [[UHMAudioController sharedAudioController] playHat];
            hat = NO;
        }
        
        if (self.deviceMotion.userAcceleration.z < 0.8) {
            kick = YES;
        }
        
        if (self.deviceMotion.userAcceleration.y < 0.8) {
            hat = YES;
        }
        
        if (filteredAcceleration > 1.0) {
            static int prevChange;
            int playhead = [[UHMAudioController sharedAudioController] playheadPosition];
            
            if (playhead != prevChange) {
                [viewController.playScene.harmony updateHarmonyForPlayheadPosition:playhead];
                prevChange = playhead;
            }
            
        }
        
        else if (filteredAcceleration > 0.5) {
            static int prevBassChange;
            int playhead = [[UHMAudioController sharedAudioController] playheadPosition];
            
            if (playhead != prevBassChange && playhead % 4 == 0 && playhead != 0) {
                [viewController.playScene.harmony updateBassPitch];
                prevBassChange = playhead;
            }
        }
    }
}

double synthGainEnvelopeTransferFunction(double input) {
//    if (input < 1.0) return input * 2.0;
//    else if (input < 2.0) return log(input) + 2.0;
//    else return pow(input, 2.0) + log(2.0) - 2.0;
    if (input > 2.0) return pow(input, 2.0) + log(2.0) - 2.0;
    return exp(-2.0 * input) * 25.0;
}

double synthFilterCutoffTransferFunction(double input) {
//    double output;
//    if (input < 1.0) output = input * 1000.0;
//    else if (input >= 1.0) output = pow(input, 8.0) + input * 2000.0 - 999.0;
//    return output > 22000.0 ? 22000.0 : output;
    return pow(input, 4.0) * 200.0 + 200.0;
}

double kickFilterCutoffTransferFunction(double input) {
    double output;
    output = 2000.0 / pow(input+1.0, 6.0);
    output = output < 0.0 ? 0.0 : output;
    return output > 2000.0 ? 2000.0 : output;
}

-(void)updateRestrictedRoll {
    CMQuaternion quaternion = self.deviceMotion.attitude.quaternion;
    double rollQuat = asin(2*(quaternion.x * quaternion.z - quaternion.w * quaternion.y));
    self.roll = -1 * rollQuat;
}

-(void)updateSmoothedAttitude {
    self.smoothPitch = [self filterMeasurement:self.deviceMotion.attitude.pitch
                                      withFilter:[self.filters valueForKey:@"pitch"]
                                       smoothing:0.1];
    
    self.smoothRoll = [self filterMeasurement:self.roll
                                     withFilter:[self.filters valueForKey:@"roll"]
                                      smoothing:0.1];
}

-(double)filterMeasurement:(double)measurement withFilter:(UHMLowPassFilter*)filter smoothing:(double)smoothing {
    return [filter filterSignal:measurement withSmoothingFactor:smoothing];
}

@end
