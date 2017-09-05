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

@interface JHPlayerController() <JHOverlayViewProtocol>

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) JHPlayerView *playerView;

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
    self.playerView.delegate = self;
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
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                // Ready to Play
                
                [self.player play];
                
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

@end
