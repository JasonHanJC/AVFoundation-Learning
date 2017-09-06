//
//  AVAsset+Addition.m
//  AVPlayer
//
//  Created by Juncheng Han on 9/5/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "AVAsset+Addition.h"

@implementation AVAsset (Addition)

- (NSString *)title {
    AVKeyValueStatus status = [self statusOfValueForKey:@"commonMetadata" error:nil];
    
    if (status == AVKeyValueStatusLoaded) {
        NSArray *items =
            [AVMetadataItem metadataItemsFromArray:self.commonMetadata
                                           withKey:AVMetadataCommonKeyTitle
                                          keySpace:AVMetadataKeySpaceCommon];
        
        if (items.count > 0) {
            AVMetadataItem *titleItem = [items firstObject];
            return titleItem.stringValue;
        }
    }
    
    return nil;
}

@end
