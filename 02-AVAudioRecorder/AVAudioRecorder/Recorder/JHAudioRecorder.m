//
//  JHAudioRecorder.m
//  AVAudioRecorder
//
//  Created by Juncheng Han on 8/15/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "JHAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioLevels.h"
#import "Record.h"

@interface JHAudioRecorder() <AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) JHRecordingStopCompletionHandler stopCompltHandler;

@end

@implementation JHAudioRecorder

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Create a temperary location for recording
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *filePath = [tmpDir stringByAppendingPathComponent:@"record.caf"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        // configure recording settings
        NSDictionary *setting = @{
                                  AVFormatIDKey : @(kAudioFormatAppleIMA4),
                                  AVSampleRateKey : @44100.0f,
                                  AVNumberOfChannelsKey : @1,
                                  AVEncoderBitDepthHintKey : @16,
                                  AVEncoderAudioQualityKey : @(AVAudioQualityMedium)
                                  };
        
        // Create AVAudioRecorder
        NSError *error;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:setting error:&error];
        
        if (self.recorder) {
            self.recorder.delegate = self;
            self.recorder.meteringEnabled = YES;
            [self.recorder prepareToRecord];
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)currentTime {
    NSUInteger time = (NSUInteger)self.recorder.currentTime;
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    return [NSString stringWithFormat:format, hours, minutes, seconds];
}

#pragma mark - public methods

- (BOOL)record {
    return [self.recorder record];
}

- (void)pause {
    [self.recorder pause];
}

- (void)stopWithCompletionHandler:(JHRecordingStopCompletionHandler)completionHandler {
    self.stopCompltHandler = completionHandler;
    [self.recorder stop];
}

- (void)saveWithName:(NSString *)name completionHandler:(JHRecordingSaveCompletionHandler)completionHandler {
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *fileName = [NSString stringWithFormat:@"%@-%f.caf", name, timestamp];
    
    // save the audio in Documents location
    NSString *docsDir = [self documentsDirection];
    NSString *destPath = [docsDir stringByAppendingPathComponent:fileName];
    
    // get the tmp path
    NSURL *srcURL = self.recorder.url;
    // create dest path
    NSURL *destURL = [NSURL fileURLWithPath:destPath];
    
    // copy the file from tmp to documents location
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:srcURL toURL:destURL error:&error];
    if (success) {
        completionHandler(YES, [Record recordWithTitle:name url:destURL]);
    } else {
        completionHandler(YES, error);
    }
}

- (AudioLevels *)levels {
    // update meters before get latest levels
    [self.recorder updateMeters];
    
    float avgLevel = [self.recorder averagePowerForChannel:0];
    float peakLevel = [self.recorder peakPowerForChannel:0];
    
    float linearAvgLevel = powf(10, avgLevel / 20.0);
    float linearPeakLevel = powf(10, peakLevel / 20.0);
    
    AudioLevels *levels = [AudioLevels audioLevelsWithAvgLevel:linearAvgLevel peakLevel:linearPeakLevel];
    return levels;
}

- (BOOL)isRecording {
    if (self.recorder) {
        return self.recorder.isRecording;
    } else {
        return false;
    }
}

#pragma mark - audio recorder delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self.stopCompltHandler) {
        self.stopCompltHandler(flag);
    }
}

- (NSString *)documentsDirection {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return path;
}

- (void)playbackRecord:(Record *)record {
    [self.player stop];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:record.fileURL error:nil];
    if (self.player) {
        [self.player play];
    }
}

- (void)handleInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self.recorder pause];
        if (self.delegate) {
            [self.delegate recordingInterrupted];
        }
    }
}

@end
