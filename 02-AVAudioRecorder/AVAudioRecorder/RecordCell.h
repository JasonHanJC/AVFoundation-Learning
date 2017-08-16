//
//  RecordCell.h
//  AVAudioRecorder
//
//  Created by Juncheng Han on 8/15/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *recordNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordDatelabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;


@end
