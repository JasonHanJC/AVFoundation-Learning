//
//  AudioLevels.h
//  AVAudioRecorder
//
//  Created by Juncheng Han on 8/17/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioLevels : NSObject

@property (nonatomic, readonly) float avgLevel;
@property (nonatomic, readonly) float peakLevel;

+ (instancetype)audioLevelsWithAvgLevel:(float)avg peakLevel:(float)peak;

@end
