//
//  UIView+Constraint.m
//  TheOhzone
//
//  Created by Juncheng Han on 12/14/16.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import "UIView+Constraint.h"

@implementation UIView (Constraint)


- (void)addConstraintsWithFormat:(NSString *)formatString views:(UIView *)view, ... NS_REQUIRES_NIL_TERMINATION {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    va_list args;
    va_start(args, view);
    if (view) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        int i = 0;
        
        [dictionary setObject:view forKey:[NSString stringWithFormat:@"v%d", i]];
        i++;
        while (1) {
            UIView *view = va_arg(args, UIView *);
            if (view == nil) {
                break;
            } else {
                view.translatesAutoresizingMaskIntoConstraints = NO;
                [dictionary setObject:view forKey:[NSString stringWithFormat:@"v%d", i]];
                i++;
            }
        }
    }
    va_end(args);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:dictionary]];
}

@end
