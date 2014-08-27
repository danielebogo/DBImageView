//
//  UIImageView+DBImage.h
//  DBImageView
//
//  Created by iBo on 27/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@class DBImage;
@interface UIImageView (DBImage)
@property (nonatomic, strong) DBImage *remoteImage;
@property (nonatomic, strong) UIImage *placeHolder;

+ (void) triggerImageRequests:(BOOL)start;
@end