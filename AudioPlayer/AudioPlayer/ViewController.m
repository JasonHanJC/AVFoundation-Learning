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

@end

float const defaultPan = 0.5;
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

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.audioPlayer stop];
        [sender setTitle:@"Play" forState:UIControlStateNormal];
    }
    
}

- (IBAction)resetAllValue:(UIButton *)sender {
    
    self.panSlider_1.value = defaultPan;
    self.panSlider_2.value = defaultPan;
    
    self.volumeSlider_1.value = defaultVolume;
    self.volumeSlider_2.value = defaultVolume;
    
    self.rateSlider.value = defaultRate;
    
    for (NSInteger i = 0;i<2;i++) {
        [self.audioPlayer adjustPan:defaultPan forPlayerAtIndex:i];
        [self.audioPlayer adjustVolume:defaultVolume forPlayerAtIndex:i];
    }
    
    [self.audioPlayer adjustPlayRate:defaultRate];
}


@end
