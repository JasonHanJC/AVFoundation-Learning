//
//  ViewController.m
//  AudioPlayer
//
//  Created by Juncheng Han on 8/14/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "ViewController.h"
#import "JHAudioPlayer.h"

@interface ViewController () <JHAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) JHAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UISlider *panSlider_1;
@property (weak, nonatomic) IBOutlet UISlider *panSlider_2;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider_1;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider_2;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@property (weak, nonatomic) IBOutlet UILabel *decibelLabel_1;
@property (weak, nonatomic) IBOutlet UILabel *decibelLabel_2;

@property (strong, nonatomic) CADisplayLink *displayLink;

@end

float const defaultPan = 0;
float const defaultVolume = 1.0;
float const defaultRate = 1;

@implementation ViewController

- (JHAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[JHAudioPlayer alloc] init];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
    self.displayLink.preferredFramesPerSecond = 12;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.displayLink setPaused:YES];
}

- (void)updateMeter {
    
    [self.audioPlayer updateMeterForPlayer:0];
    self.decibelLabel_1.text = [NSString stringWithFormat:@"%0.3f dB", [self.audioPlayer getAveragePowerForPlayer:0]];
    [self.audioPlayer updateMeterForPlayer:1];
    self.decibelLabel_2.text = [NSString stringWithFormat:@"%0.3f dB", [self.audioPlayer getAveragePowerForPlayer:1]];
    
}

#pragma mark - IBActions
- (IBAction)adjustPan:(UISlider *)sender {
    [self.audioPlayer adjustPan:sender.value forPlayerAtIndex:sender.tag];
}

- (IBAction)adjustVolume:(UISlider *)sender {
    [self.audioPlayer adjustVolume:sender.value forPlayerAtIndex:sender.tag];
}


- (IBAction)adjustPlayRate:(UISlider *)sender {
    [self.audioPlayer adjustPlayRate:sender.value];
}

- (IBAction)playButtonAction:(UIButton *)sender {
    if (!self.audioPlayer.isPlaying) {
        [self.audioPlayer play];
        [self.displayLink setPaused:NO];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.audioPlayer stop];
        [self.displayLink setPaused:YES];
        [sender setTitle:@"Play" forState:UIControlStateNormal];
    }
    
}

- (IBAction)resetAllValue:(UIButton *)sender {
    
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        [self.displayLink setPaused:YES];
        [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    // reset sliders
    self.panSlider_1.value = defaultPan;
    self.panSlider_2.value = defaultPan;
    
    self.volumeSlider_1.value = defaultVolume;
    self.volumeSlider_2.value = defaultVolume;
    
    self.rateSlider.value = defaultRate;
    
    // reset pan, volume and rate
    for (NSInteger i = 0;i<2;i++) {
        [self.audioPlayer adjustPan:defaultPan forPlayerAtIndex:i];
        [self.audioPlayer adjustVolume:defaultVolume forPlayerAtIndex:i];
    }
    
    [self.audioPlayer adjustPlayRate:defaultRate];
    
    // reset decibel labels
    self.decibelLabel_1.text = @"0.0 dB";
    self.decibelLabel_2.text = @"0.0 dB";
}

#pragma mark - Audio player delegate

- (void)playbackStopped {
    [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)playbackBegan {
    [self.playBtn setTitle:@"Stop" forState:UIControlStateNormal];
}


@end
