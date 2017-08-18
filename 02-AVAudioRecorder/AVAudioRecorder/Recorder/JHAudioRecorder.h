//
//  JHAudioRecorder.h
//  AVAudioRecorder
//
//  Created by Juncheng Han on 8/15/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JHAudioRecorderDelegate <NSObject>

@optional
- (void)recordingInterrupted;

@end

typedef void(^JHRecordingStopCompletionHandler)(BOOL);
typedef void(^JHRecordingSaveCompletionHandler)(BOOL, id);

@class AudioLevels;
@class Record;

@interface JHAudioRecorder : NSObject

@property (nonatomic, readonly) NSString *currentTime;
@property (weak, nonatomic) id <JHAudioRecorderDelegate> delegate;
@property (assign, nonatomic, getter=isRecording) BOOL recording;

- (BOOL)record;
- (void)pause;
- (void)stopWithCompletionHandler:(JHRecordingStopCompletionHandler)completionHandler;
- (void)saveWithName:(NSString *)name completionHandler:(JHRecordingSaveCompletionHandler)completionHandler;

- (AudioLevels *)levels;
- (void)playbackRecord:(Record *)record;

@end
