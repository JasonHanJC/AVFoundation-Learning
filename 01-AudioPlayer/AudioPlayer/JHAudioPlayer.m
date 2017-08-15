//
//  JHAudioPlayer.m
//  AudioPlayer
//
//  Created by Juncheng Han on 8/14/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "JHAudioPlayer.h"

@interface JHAudioPlayer()

@property (nonatomic, strong) NSArray *players;

@end

@implementation JHAudioPlayer

#pragma mark - Lifetime

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        AVAudioPlayer *player_1 = [self playerFileName:@"362832__4barrelcarb__nylon-string-guitar-with-steel-string-bass" withExtension:@"mp3"];
        AVAudioPlayer *player_2 = [self playerFileName:@"381353__waveplay__120-bpm-basic-drum-loop" withExtension:@"wav"];
        
        _players = @[player_1, player_2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:[AVAudioSession sharedInstance]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:[AVAudioSession sharedInstance]];

    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AVAudioPlayer *)playerFileName:(NSString *)name withExtension:(NSString *)extension {
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:name withExtension:extension];
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err];
    
    if (player) {
        player.numberOfLoops = -1; // infinite loop
        player.enableRate = YES;
        player.meteringEnabled = YES;
        player.volume = 1.0f;
        player.pan = 0.0f;
        player.rate = 1.0f;
        [player prepareToPlay];
    } else {
        NSLog(@"%@", [err localizedDescription]);
    }
    
    return player;
}

#pragma mark - Global methods

- (void)play {
    if (!self.playing) {
        for (AVAudioPlayer *player in self.players) {
            [player play];
        }
        self.playing = YES;
    }
    
}

- (void)stop {
    if (self.playing) {
        for (AVAudioPlayer *player in self.players) {
            [player stop];
            player.currentTime = 0.0f;
        }
        self.playing = NO;
    }
}

- (void)adjustPlayRate:(float)value {
    for (AVAudioPlayer *player in self.players) {
        player.rate = value;
    }
}

- (void)adjustVolume:(float)value forPlayerAtIndex:(NSUInteger)index {
    if ([self isValidIndex:index]) {
        AVAudioPlayer *player = self.players[index];
        player.volume = value;
    }
}

- (void)adjustPan:(float)value forPlayerAtIndex:(NSUInteger)index {
    if ([self isValidIndex:index]) {
        AVAudioPlayer *player = self.players[index];
        player.pan = value;
    }
}

- (BOOL)isValidIndex:(NSUInteger)index {
    return index == 0 || index<self.players.count;
}

- (float)getAveragePowerForPlayer:(NSUInteger)index {
    if ([self isValidIndex:index]) {
        return [(AVAudioPlayer *)self.players[index] averagePowerForChannel:0];
    } else {
        return 0.0;
    }
}

- (void)updateMeterForPlayer:(NSUInteger)index {
    if ([self isValidIndex:index]) {
        [self.players[index] updateMeters];
    }
}

#pragma mark - NSNotification Handler
- (void)handleRouteChange:(NSNotification *)notification {
    
    AVAudioSessionRouteChangeReason reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *preRoute = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        NSString *portType = [[preRoute.outputs firstObject] portType];
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self stop];
            if (self.delegate) {
                [self.delegate playbackStopped];
            }
        }
    }
}

- (void)handleInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self stop];
        if (self.delegate) {
            [self.delegate playbackStopped];
        }
    }else if (type == AVAudioSessionInterruptionTypeEnded) {
        [self play];
        if (self.delegate) {
            [self.delegate playbackBegan];
        }
    }
}

@end
