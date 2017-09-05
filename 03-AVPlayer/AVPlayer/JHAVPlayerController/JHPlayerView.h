//
//  JHPlayerView.h
//  AVPlayer
//
//  Created by Juncheng Han on 8/22/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHOverlayView.h"


@class AVPlayer;

@interface JHPlayerView : UIView

// initializer
- (instancetype)initWithAVPlayer:(AVPlayer *)player;

@property (weak, nonatomic) id<JHOverlayViewProtocol> delegate;

@end
