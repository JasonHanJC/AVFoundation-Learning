//
//  JHOverlayView.h
//  AVPlayer
//
//  Created by Juncheng Han on 8/24/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JHOverlayViewProtocol <NSObject>

@end

@interface JHOverlayView : UIView

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic) IBOutlet UIView *transportView;
@property (weak, nonatomic) IBOutlet UIButton *subButton;
@property (weak, nonatomic) IBOutlet UIButton *playbackButton;
@property (weak, nonatomic) IBOutlet UISlider *scrubberSlider;
@property (weak, nonatomic) IBOutlet UILabel *scruberTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *airPlayButton;

- (IBAction)togglePlayback:(UIButton *)sender;
- (IBAction)toggleSub:(UIButton *)sender;
- (IBAction)closePlayback:(UIBarButtonItem *)sender;
- (void)toggleControl:(UITapGestureRecognizer *)sender;

@property (weak, nonatomic) id<JHOverlayViewProtocol> delegate;

@end
