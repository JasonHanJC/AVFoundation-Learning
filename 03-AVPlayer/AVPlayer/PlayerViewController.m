//
//  PlayerViewController.m
//  AVPlayer
//
//  Created by Juncheng Han on 8/23/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "PlayerViewController.h"
#import "JHPlayerController.h"

@interface PlayerViewController () <JHOverlayViewProtocol>

@property (nonatomic, strong) JHPlayerController *playerController;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_assetURL) {
        self.playerController = [[JHPlayerController alloc] initWithURL:_assetURL];
        self.playerController.view.frame = self.view.frame;
        self.playerController.delegate = self;
        [self.view addSubview:self.playerController.view];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - JHOverlayViewProtocol
- (void)closePlaybackWindow {
    [self.playerController stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)togglePlayback:(BOOL)shoudPlay {
    if (shoudPlay) {
        [self.playerController play];
    } else {
        [self.playerController pause];
    }
}

- (void)scrubbingDidStart {
    // when scrubbing started, pause the video, don't use sweakSelftop!!
    [self.playerController removeTimeObserver];
    [self.playerController pause];
}

- (void)scrubbingDidEnd {
    // when scrubbing ended, play the video
    [self.playerController addTimeObserver];
    [self.playerController play];
}

- (void)scrubbedToTime:(NSTimeInterval)time {
    [self.playerController seekToTime:time];
}


@end
