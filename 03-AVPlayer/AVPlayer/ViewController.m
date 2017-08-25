//
//  ViewController.m
//  AVPlayer
//
//  Created by Juncheng Han on 8/21/17.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playLocalFile:(UIButton *)sender {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"hubblecast" withExtension:@"m4v"];
    
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    playerViewController.assetURL = url;
    
    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (IBAction)playStreamFile:(UIButton *)sender {
    
    NSString *urlString = @"https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726";
    
    NSURL *url = [NSURL URLWithString:urlString];
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    playerViewController.assetURL = url;
    
    [self presentViewController:playerViewController animated:YES completion:nil];
}
@end
