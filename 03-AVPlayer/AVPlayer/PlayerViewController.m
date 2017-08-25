//
//  PlayerViewController.m
//  AVPlayer
//
//  Created by Juncheng Han on 8/23/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "PlayerViewController.h"
#import "JHPlayerController.h"

@interface PlayerViewController ()

@property (nonatomic, strong) JHPlayerController *playerController;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_assetURL) {
        self.playerController = [[JHPlayerController alloc] initWithURL:_assetURL];
        self.playerController.view.frame = self.view.frame;
        [self.view addSubview:self.playerController.view];
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
