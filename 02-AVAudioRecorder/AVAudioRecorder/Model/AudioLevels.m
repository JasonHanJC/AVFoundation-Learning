//
//  AudioLevels.m
//  AVAudioRecorder
//
//  Created by Juncheng Han on 8/17/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "AudioLevels.h"

@implementation AudioLevels

+ (instancetype)audioLevelsWithAvgLevel:(float)avg peakLevel:(float)peak {
    return [[self alloc] initWithAvgLevel:avg peakLevel:peak];
}

- (instancetype)initWithAvgLevel:(float)avg peakLevel:(float)peak {
    self = [super init];
    if (self) {
        _avgLevel = avg;
        _peakLevel = peak;
    }
    
    return self;
}


@end
