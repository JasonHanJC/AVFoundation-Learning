//
//  JHPlayerController.m
//  AVPlayer
//
//  Created by Juncheng Han on 8/22/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "JHPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "JHPlayerView.h"

static const NSString *PlayerItemContext;

@interface JHPlayerController()

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) JHPlayerView *playerView;

@property (nonatomic, strong) id timeObserver;

@end

@implementation JHPlayerController

#pragma mark - init

- (instancetype)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        
        // Setup audio session catagory, use playback for video playback
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        NSError *error;
        if (![session setCategory:AVAudioSessionCategoryPlayback error:&error]) {
            NSLog(@"Category Error: %@", [error localizedDescription]);
        }
        
        if (![session setActive:YES error:&error]) {
            NSLog(@"Activation Error: %@", [error localizedDescription]);
        }
        
        // Prepare asset
        _asset = [AVAsset assetWithURL:assetURL];
        
        [self prepareToPlay];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareToPlay {
    
    NSArray *keys = @[
                      @"tracks",
                      @"duration",
                      @"commonMetadata",
                      @"availableMediaCharacteristicsWithMediaSelectionOptions"
                      ];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset
                           automaticallyLoadedAssetKeys:keys];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:options
                         context:&PlayerItemContext];
    
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerView = [[JHPlayerView alloc] initWithAVPlayer:self.player];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    // Only handle observations for the PlayerItemContext
    if (context != &PlayerItemContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        
        // Remenber to remove the observer, if you forget, the app might crash after you dismiss the playerViewController
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                // Get the total duration
                CMTime duration = self.playerItem.duration;
                // Set overlay view duration
                [self.playerView.overlayView setCurrentTime:CMTimeGetSeconds(kCMTimeZero)
                                                   duration:CMTimeGetSeconds(duration)];
                
                // Add time observer for update remaining time
                [self addObservers];
                
                // Ready to Play
                [self.player play];
            }
                break;
            case AVPlayerItemStatusFailed:
                [self popErrorAlert:self.playerItem.error];
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }
}

#pragma mark - Interfaces

- (void)play {
    [self.player play];
    self.playerView.overlayView.playbackButton.selected = YES;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)pause {
    [self.player pause];
    self.playerView.overlayView.playbackButton.selected = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)stop {
    [self.player pause];
    self.playerView.overlayView.playbackButton.selected = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.player = nil;
}

- (void)seekToTime:(NSTimeInterval)time {
    
    if (!self.player)
        return;
    
    // cancel the previous seekings
    [self.playerItem cancelPendingSeeks];
    int32_t timeScale = self.player.currentItem.asset.duration.timescale;

    [self.player.currentItem seekToTime:CMTimeMakeWithSeconds(time, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)addTimeObserver {
    // 0.5s interval
    CMTime interval = CMTimeMake(1.0, 2.0);
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.playerView.overlayView setCurrentTime:currentTime duration:duration];
        
    }];
}

- (void)removeTimeObserver {
    [self.player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
}

#pragma mark - private methods

- (void)addObservers {
    [self addTimeObserver];
    [self addPlaybackEndObserver];
    [self addInterruptionObserver];
    [self addFailPlayToEndObserver];
    [self addRouteChangeObserver];
}

- (void)addPlaybackEndObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(haddlePlayerDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
}

- (void)addInterruptionObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(haddleSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
}

- (void)addFailPlayToEndObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(haddleAVPlayerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
}

- (void)addRouteChangeObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

- (void)haddleAVPlayerItemFailedToPlayToEndTime:(NSNotification *)notification {
    NSError *error = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    
    // This notification was send from other thread, pop up error message under main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popErrorAlert:error];
    });
}

- (void)haddleSessionInterruption:(NSNotification *)notification {
    
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
    
        // pause the video
        [self pause];
        
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        
        // resume the video
        // [self.player play];
        
        // update the playback button
        // self.playerView.overlayView.playbackButton.selected = YES;
    }
}

- (void)haddlePlayerDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *playerItem = (AVPlayerItem *)notification.object;
    
    // Jump to the beginning of the video
    [playerItem seekToTime:kCMTimeZero];
    // pause the video
    [self pause];
}

- (void)handleRouteChange:(NSNotification *)notification {
    
    AVAudioSessionRouteChangeReason reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    
    
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *preRoute = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        NSString *portType = [[preRoute.outputs firstObject] portType];
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // pause the video
                [self pause];
            });
        }
    }
}

- (void)popErrorAlert:(NSError *)error {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.description preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // dismiss the playerViewController
        [[self topMostController] dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    
    [[self topMostController] presentViewController:alertController animated:YES completion:nil];
}

- (UIViewController *)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

#pragma mark - interface

- (UIView *)view {
    return self.playerView;
}

- (void)setDelegate:(id<JHOverlayViewProtocol>)delegate {
    self.playerView.delegate = delegate;
}

@end
