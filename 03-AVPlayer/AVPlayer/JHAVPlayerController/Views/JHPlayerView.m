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
        [(AVPlayerLayer *)[self layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        // add player to avplayerlayer
        [(AVPlayerLayer *)[self layer] setPlayer:player];
        
        // Load the overlay view from xib
        // Add the overlay view over the JHPlayerView
        self.overlayView = [[[NSBundle mainBundle] loadNibNamed:@"JHOverlayView"
                                                      owner:self
                                                    options:nil] firstObject];
        
        [self addSubview:self.overlayView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    // Set overlay view's frame
    self.overlayView.frame = self.bounds;
}

- (void)setDelegate:(id<JHOverlayViewProtocol>)delegate {
    self.overlayView.delegate = delegate;
}

@end
