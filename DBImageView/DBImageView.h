//
//  DBImageView.h
//  DBImageView
//
//  Created by iBo on 25/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBImageView : UIView
@property (nonatomic, copy) NSString *imageWithPath;
@property (nonatomic, strong) UIImage *placeHolder, *image;

+ (void) triggerImageRequests:(BOOL)start;
+ (void) clearCache;
@end