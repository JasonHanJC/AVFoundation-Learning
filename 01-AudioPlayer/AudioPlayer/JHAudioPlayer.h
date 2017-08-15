//
//  JHAudioPlayer.h
//  AudioPlayer
//
//  Created by Juncheng Han on 8/14/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol JHAudioPlayerDelegate <NSObject>

@optional
- (void)playbackStopped;
- (void)playbackBegan;

@end

@interface JHAudioPlayer : NSObject

@property (nonatomic, getter=isPlaying) BOOL playing;
@property (nonatomic, weak) id <JHAudioPlayerDelegate> delegate;

- (void)play;
- (void)stop;

- (void)adjustPan:(float)value forPlayerAtIndex:(NSUInteger)index;
- (void)adjustVolume:(float)value forPlayerAtIndex:(NSUInteger)index;
- (void)adjustPlayRate:(float)value;

- (void)updateMeterForPlayer:(NSUInteger)index;
- (float)getAveragePowerForPlayer:(NSUInteger)index;

@end
