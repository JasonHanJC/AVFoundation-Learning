//
//  JHPlayerView.m
//  AVPlayer
//
//  Created by Juncheng Han on 8/22/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "JHPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation JHPlayerView

// override the UIView layerClass method to set avplayerlayer as backing layer
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithAVPlayer:(AVPlayer *)player {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // configure player layer gravity
        // default is AVLayerVideoGravityResizeAspect
        //[(AVPlayerLayer *)[self layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        
        // add player to avplayerlayer
        [(AVPlayerLayer *)[self layer] setPlayer:player];
    }
    return self;
}

@end
