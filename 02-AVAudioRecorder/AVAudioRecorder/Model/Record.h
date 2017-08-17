//
//  Record.h
//  AVAudioRecorder
//
//  Created by Juncheng Han on 8/17/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject <NSCoding>

/*
 * Recorder is used for storing the recording data
 * Table view will use this model to display all data
 */

@property (copy, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSURL *fileURL;
@property (copy, nonatomic, readonly) NSString *dateString;
@property (copy, nonatomic, readonly) NSString *timeString;

+ (instancetype)recordWithTitle:(NSString *)title url:(NSURL *)url;
- (BOOL)deleteRecord;

@end
