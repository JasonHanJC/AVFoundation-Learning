//
//  Record.m
//  AVAudioRecorder
//
//  Created by Juncheng Han on 8/17/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "Record.h"

#define TITLE_KEY @"title"
#define URL_KEY @"fileURL"
#define DATE_STRING_KEY @"dateString"
#define TIME_STRING_KEY @"timeString"

@implementation Record

#pragma mark - public methods

+ (instancetype)recordWithTitle:(NSString *)title url:(NSURL *)url {
    return [[self alloc] initWithTitle:title url:url];
}

- (BOOL)deleteRecord {
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:self.fileURL error:&error];
    if (!success) {
        NSLog(@"Unable to delete: %@", [error localizedDescription]);
    }
    return success;
}

#pragma mark - Initializer

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url {
    self = [super init];
    if (self) {
        _title = [title copy];
        _fileURL = url;
        
        NSDate *date = [NSDate date];
        _dateString = [self dateStringWithDate:date];
        _timeString = [self timeStringWithDate:date];
        
    }
    return self;
}

#pragma mark - NSCoding delegate
// We are trying to store the object into files

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:TITLE_KEY];
    [aCoder encodeObject:self.fileURL forKey:URL_KEY];
    [aCoder encodeObject:self.dateString forKey:DATE_STRING_KEY];
    [aCoder encodeObject:self.timeString forKey:TIME_STRING_KEY];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:TITLE_KEY];
        _fileURL = [aDecoder decodeObjectForKey:URL_KEY];
        _dateString = [aDecoder decodeObjectForKey:DATE_STRING_KEY];
        _timeString = [aDecoder decodeObjectForKey:TIME_STRING_KEY];
    }
    return self;
}

#pragma mark - internal methods
- (NSString *)dateStringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithFormat:@"MMddyyyy"];
    return [formatter stringFromDate:date];
}

- (NSString *)timeStringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithFormat:@"HHmmss"];
    return [formatter stringFromDate:date];
}

- (NSDateFormatter *)formatterWithFormat:(NSString *)template {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];
    return formatter;
}

@end
