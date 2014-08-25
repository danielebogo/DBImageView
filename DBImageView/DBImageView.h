//
//  DBImageView.h
//  DBImageView
//
//  Created by iBo on 25/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBImage;
@interface DBImageView : UIView
@property (nonatomic, strong) DBImage *remoteImage;
@property (nonatomic, strong) UIImage *placeHolder, *image;

+ (void) triggerImageRequests:(BOOL)start;
@end