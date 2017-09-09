//
//  UIView+Constraint.h
//  TheOhzone
//
//  Created by Juncheng Han on 12/14/16.
//  Copyright © 2017 Jason H. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Constraint)

- (void)addConstraintsWithFormat:(NSString *)formatString views:(UIView *)view, ... NS_REQUIRES_NIL_TERMINATION;

@end
