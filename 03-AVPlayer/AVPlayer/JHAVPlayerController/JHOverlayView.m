//
//  JHOverlayView.m
//  AVPlayer
//
//  Created by Juncheng Han on 8/24/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "JHOverlayView.h"

@interface JHOverlayView() <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL controlsHidden;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL scrubbing;

@end

@implementation JHOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.transportView.layer.cornerRadius = 8;
    self.transportView.layer.masksToBounds = YES;
    
    self.subButton.hidden = YES;
    self.airPlayButton.hidden = YES;
    
    UIImage *thumbNormalImage = [UIImage imageNamed:@"knob"];
    UIImage *thumbHighlightedImage = [UIImage imageNamed:@"knob_highlighted"];
    [self.scrubberSlider setThumbImage:thumbNormalImage forState:UIControlStateNormal];
    [self.scrubberSlider setThumbImage:thumbHighlightedImage forState:UIControlStateHighlighted];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControl:)];
    singleTap.delegate = self;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    self.scrubbing = false;
    self.controlsHidden = false;
    
    [self resetTimer];
}

// bypass the single tap gestrue for navigation bar and transport view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    [self resetTimer];
    if ([touch.view isDescendantOfView:self.navigationBar] || [touch.view isDescendantOfView:self.transportView]) {
        return NO;
    }
    return YES;
}

- (void)resetTimer {
    [self.timer invalidate];
    if (!self.scrubbing) {
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [weakSelf toggleControl:nil];
        }];
    }
}

- (IBAction)togglePlayback:(UIButton *)sender {
    NSLog(@"nnn");
}

- (IBAction)toggleSub:(UIButton *)sender {
    NSLog(@"nnn");
}

- (IBAction)closePlayback:(UIBarButtonItem *)sender {
    NSLog(@"nnn");
}

- (void)toggleControl:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.35 animations:^{
        if (!self.controlsHidden) {
            self.navigationBar.frame = CGRectMake(self.navigationBar.frame.origin.x, self.navigationBar.frame.origin.y - self.navigationBar.frame.size.height, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height);
            self.transportView.frame = CGRectMake(self.transportView.frame.origin.x, self.transportView.frame.origin.y + (self.transportView.frame.size.height + 10), self.transportView.frame.size.width, self.transportView.frame.size.height);
        } else {
            self.navigationBar.frame = CGRectMake(self.navigationBar.frame.origin.x, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height);
            self.transportView.frame = CGRectMake(self.transportView.frame.origin.x, self.transportView.frame.origin.y - (self.transportView.frame.size.height + 10), self.transportView.frame.size.width, self.transportView.frame.size.height);
        }
        self.controlsHidden = !self.controlsHidden;
    }];
}
@end
