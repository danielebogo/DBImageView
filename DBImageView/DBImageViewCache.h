//
//  DBImageViewCache.h
//  DBImageView
//
//  Created by iBo on 25/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBImageViewCache : NSObject
@property (nonatomic, strong) NSString *localDirectory;

+ (instancetype) cache;
- (void) clearCache;
- (void) imageForURL:(NSURL *)imageURL found:(void(^)(UIImage* image))found notFound:(void(^)())notFound;
- (BOOL) saveImageFromName:(NSString *)imageName data:(NSData *)imageData;
@end