//
//  JHPlayerController.h
//  AVPlayer
//
//  Created by Juncheng Han on 8/22/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JHPlayerController : NSObject

- (instancetype)initWithURL:(NSURL *)assetURL;

@property (nonatomic, strong, readonly) UIView *view;

@end
