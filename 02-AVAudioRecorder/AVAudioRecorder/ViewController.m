//
//  ViewController.m
//  AVAudioRecorder
//
//  Created by Juncheng Han on 8/15/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "ViewController.h"
#import "Record.h"
#import "JHAudioRecorder.h"
#import "AudioLevels.h"
#import "RecordCell.h"

@interface ViewController () <JHAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIProgressView *averageBar;
@property (weak, nonatomic) IBOutlet UIProgressView *peakBar;

@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) JHAudioRecorder *audioRecorder;
@property (strong, nonatomic) NSMutableArray *records;

@property (strong, nonatomic) CADisplayLink *levelTimer;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) BOOL recording;

@end

NSString * const cellId = @"RecordCell";
NSString * const recordsArchive = @"records.archive";
NSString * const defaultRecordName = @"My recording";
NSString * const resetTimeLabelText = @"00:00:00";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _audioRecorder = [[JHAudioRecorder alloc] init];
    _audioRecorder.delegate = self;
    
    _records = [NSMutableArray array];
    
    // get stored records data from file
    NSData *data = [NSData dataWithContentsOfURL:[self archiveURL]];
    if (data) {
        // unarchive the data to records
        _records = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        _records = [NSMutableArray array];
    }
    
    self.stopBtn.enabled = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - records archive

- (void)saveRecords {
    // archive the data
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:self.records];
    [fileData writeToURL:[self archiveURL] atomically:YES];
}

- (NSURL *)archiveURL {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *archivePath = [docPath stringByAppendingPathComponent:recordsArchive];
    return [NSURL fileURLWithPath:archivePath];
}

#pragma mark - IBActions

- (IBAction)startRecord:(UIButton *)sender {
    self.stopBtn.enabled = YES;
    if (!self.audioRecorder.isRecording) {
        [self startMeterTimer];
        [self startTimer];
        [self.audioRecorder record];
        [self.recordBtn setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [self stopMeterTimer];
        [self stopTimer];
        [self.audioRecorder pause];
        [self.recordBtn setTitle:@"Record" forState:UIControlStateNormal];
    }
}

- (IBAction)stopRecord:(UIButton *)sender {
    [self stopMeterTimer];
    [self stopTimer];
    [self.recordBtn setTitle:@"Record" forState:UIControlStateNormal];
    self.stopBtn.enabled = NO;
    self.timeLabel.text = resetTimeLabelText;
    [self.audioRecorder stopWithCompletionHandler:^(BOOL success) {
        if (success) {
            [self showSaveDialog];
        }
    }];
}

- (void)showSaveDialog {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Save" message:@"Please enter a name" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultRecordName;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *filename = [alertController.textFields.firstObject text];
        if ([filename isEqualToString:@""]) {
            filename = defaultRecordName;
        }
        [self.audioRecorder saveWithName:filename completionHandler:^(BOOL success, id object) {
            if (success) {
                [self.records addObject:object];
                [self saveRecords];
                [self.tableView reloadData];
            } else {
                NSLog(@"Error saving file: %@", [object localizedDescription]);
            }
        }];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)startMeterTimer {
    [self.levelTimer invalidate];
    self.levelTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMetering)];
    self.levelTimer.preferredFramesPerSecond = 12;
    [self.levelTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateMetering {
    AudioLevels *levels = [self.audioRecorder levels];
    self.averageBar.progress = (float)levels.avgLevel;
    self.peakBar.progress = (float)levels.peakLevel;
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.timeLabel.text = self.audioRecorder.currentTime;
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopMeterTimer {
    [self.levelTimer invalidate];
    self.levelTimer = nil;
    self.averageBar.progress = 0.0f;
    self.peakBar.progress = 0.0f;
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - table view delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RecordCell *cell = (RecordCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    // configure cell
    Record *curRecord = self.records[indexPath.row];
    cell.recordNameLabel.text = curRecord.title;
    cell.recordTimeLabel.text = curRecord.timeString;
    cell.recordDatelabel.text = curRecord.dateString;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Record *record = self.records[indexPath.row];
        // delete record audio file
        [record deleteRecord];
        // delete record from array
        [self.records removeObjectAtIndex:indexPath.row];
        // save changes for records archive
        [self saveRecords];
        // delete cell from table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Record *record = self.records[indexPath.row];
    [self.audioRecorder playbackRecord:record];
}

#pragma mark - JHAudioRecorder delegate

- (void)recordingInterrupted {
    [self stopTimer];
    [self stopMeterTimer];
    [self.recordBtn setTitle:@"Record" forState:UIControlStateNormal];
}

@end
