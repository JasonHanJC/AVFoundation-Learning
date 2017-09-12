//
//  JHOverlayView.m
//  AVPlayer
//
//  Created by Juncheng Han on 8/24/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "JHOverlayView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+Constraint.h"

@interface JHOverlayView() <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL controlsHidden;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL scrubbing;
@property (nonatomic, assign) NSTimeInterval storedDuration;
@property (weak, nonatomic) IBOutlet UILabel *airplayLabel;

@property (nonatomic, strong) MPVolumeView *volumeView;

@end

@implementation JHOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _scrubbing = false;
    _controlsHidden = false;
    
    
    self.transportView.layer.cornerRadius = 8;
    self.transportView.layer.masksToBounds = YES;
    
    self.subButton.hidden = YES;
        
    [self.playbackButton setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
    [self.playbackButton setImage:[UIImage imageNamed:@"pause_button"] forState:UIControlStateSelected];
    
    self.scruberTimeLabel.clipsToBounds = NO;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControl:)];
    singleTap.delegate = self;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    // Reset timer for hiding the transport view and navigation bar
    [self resetTimer];
    
    // Set up scrubberSlider actions
    // Send scrubbedToTime:time
    [self.scrubberSlider addTarget:self action:@selector(scrubberSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // Send scrubbingDidStart
    [self.scrubberSlider addTarget:self action:@selector(scrubberSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    // Send scrubbingDidStart
    [self.scrubberSlider addTarget:self action:@selector(scrubberSliderTouchDown:) forControlEvents:UIControlEventTouchDown];

    
    // Add notification for device changing orirentation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceWillChangeOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
    [self enableAirplay];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)enableAirplay {
    UIImage *airplayImage = [UIImage imageNamed:@"airplay"];
    self.volumeView = [[MPVolumeView alloc] init];
    self.volumeView.showsVolumeSlider = NO;
    [self.volumeView setRouteButtonImage:airplayImage forState:UIControlStateNormal];
    
    [self.volumeView sizeToFit];
    
    [self.transportView addSubview:self.volumeView];
    // layout volumeView
    [self.transportView addConstraintsWithFormat:@"H:[v0(24)]-12-|" views:self.volumeView, nil];
    [self.transportView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.transportView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

#pragma mark - IBActions

- (IBAction)togglePlayback:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate) {
        [self.delegate togglePlayback:sender.isSelected];
    }
}

- (IBAction)toggleSub:(UIButton *)sender {
    NSLog(@"toggle sub");
}

- (IBAction)closePlayback:(UIBarButtonItem *)sender {
    // clear the timer
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.delegate) {
        [self.delegate closePlaybackWindow];
    }
}

- (void)setCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.storedDuration = duration;
    // Calculate the remaining time
    double remainingTime = duration - currentTime;
    self.scruberTimeLabel.text = [self formatSeconds:remainingTime];
    self.scrubberSlider.minimumValue = 0.0f;
    self.scrubberSlider.maximumValue = duration;
    self.scrubberSlider.value = currentTime;
}

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60 % 60;
    NSInteger hours = value / 60 / 60;
    
    NSString *timeString = @"";
    if (hours != 0) {
        timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long) hours, (long) minutes, (long) seconds];
    } else {
        timeString = [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
    }

    return timeString;
}

- (void)toggleControl:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.35 animations:^{
        if (!self.controlsHidden) {
            [self hideControls];
        } else {
            [self showControls];
        }
        self.controlsHidden = !self.controlsHidden;
    }];
}

- (void)hideControls {
    self.navigationBar.frame = CGRectMake(self.navigationBar.frame.origin.x, self.navigationBar.frame.origin.y - self.navigationBar.frame.size.height, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height);
    self.transportView.frame = CGRectMake(self.transportView.frame.origin.x, self.transportView.frame.origin.y + (self.transportView.frame.size.height + 10), self.transportView.frame.size.width, self.transportView.frame.size.height);
}

- (void)showControls {
    self.navigationBar.frame = CGRectMake(self.navigationBar.frame.origin.x, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height);
    self.transportView.frame = CGRectMake(self.transportView.frame.origin.x, self.transportView.frame.origin.y - (self.transportView.frame.size.height + 10), self.transportView.frame.size.width, self.transportView.frame.size.height);
}

- (void)setTitle:(NSString *)title {
    if (title == nil || [title isEqualToString:@""]) {
        self.navigationItem.title = @"Playback";
    } else {
        self.navigationItem.title = title;
    }
}

- (void)showAirplayLabel {
    self.airplayLabel.hidden = NO;
}

- (void)hideAirplayLabel {
    self.airplayLabel.hidden = YES;
}

#pragma mark - Scrubber slider actions

- (void)scrubberSliderValueChanged:(UISlider *)sender {
    
    [self setCurrentTime:sender.value duration:self.storedDuration];
    
    if (self.delegate) {
        [self.delegate scrubbedToTime:sender.value];
    }
}

- (void)scrubberSliderTouchUpInside:(UISlider *)sender {
    // when you touch up inside the slider means scrubbing is ended.
    self.scrubbing = NO;
    [self resetTimer];
    if (self.delegate) {
        [self.delegate scrubbingDidEnd];
    }
}

- (void)scrubberSliderTouchDown:(UISlider *)sender {
    // when you touch down the slider means scrubbing is started.
    self.scrubbing = YES;
    [self resetTimer];
    if (self.delegate) {
        [self.delegate scrubbingDidStart];
    }
    
}

- (void)setScrubbing:(BOOL)scrubbing {
    // update the playback button image
    _scrubbing =  scrubbing;
    self.playbackButton.selected = !scrubbing;
}

#pragma mark - Will change orientation notification

- (void)deviceWillChangeOrientation:(NSNotification *)notification {
    self.controlsHidden = NO;
    [self resetTimer];
}
@end
