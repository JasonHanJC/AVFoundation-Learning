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
@property (nonatomic, strong) id playbackEndObserver;

@end

@implementation JHPlayerController

#pragma mark - init

- (instancetype)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        
        _asset = [AVAsset assetWithURL:assetURL];
        
        [self prepareToPlay];
        
    }
    return self;
}

- (void)dealloc {
    [self removePlaybackEndObserver];
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
                [self addTimeObserver];
                // Add play back end observer
                [self addPlaybackEndObserver];
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
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)pause {
    [self.player pause];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)stop {
    [self.player pause];
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

- (void)addPlaybackEndObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
}

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *playerItem = (AVPlayerItem *)notification.object;
    [playerItem seekToTime:kCMTimeZero];
    [self.player pause];
    self.playerView.overlayView.playbackButton.selected = NO;
}

- (void)removePlaybackEndObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)popErrorAlert:(NSError *)error {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.description preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
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
