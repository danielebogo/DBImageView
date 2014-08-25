//
//  DBImageViewCache.m
//  DBImageView
//
//  Created by iBo on 25/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "DBImageViewCache.h"

#import <CommonCrypto/CommonDigest.h>

@implementation DBImageViewCache

+ (instancetype) cache
{
    static DBImageViewCache *cacheInstance = nil;
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        cacheInstance = [[DBImageViewCache alloc] init];
    });
    
    return cacheInstance;
}

+ (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (id) init
{
    self= [super init];
    
    if ( self ) {
        [self createLocalDirectory];
    }
    
    return self;
}

- (void) createLocalDirectory
{
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:self.localDirectory] ) {
        NSError *error;
        if ( ![[NSFileManager defaultManager] createDirectoryAtPath:self.localDirectory withIntermediateDirectories:YES attributes:nil error:&error] ) {
            NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
}

- (NSString *) localDirectory
{
    return [NSString stringWithFormat:@"%@/DBImageView", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]];
}

- (NSString *) pathOnDiskForName:(NSString *)imageName
{
    return [NSString stringWithFormat:@"%@/%@", self.localDirectory, [DBImageViewCache md5:imageName]];
}

- (BOOL) loadFromCacheIfPresent:(NSString *)imageName
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self pathOnDiskForName:imageName]];
}

- (BOOL) saveImageFromName:(NSString *)imageName data:(NSData *)imageData
{
    return [[NSFileManager defaultManager] createFileAtPath:[self pathOnDiskForName:imageName]
                                                   contents:imageData attributes:nil];
}

- (void) imageForURL:(NSURL *)imageURL found:(void(^)(UIImage* image))found notFound:(void(^)())notFound
{
    if ( !imageURL ) {
        return;
    }
    
    if ( [self loadFromCacheIfPresent:[imageURL absoluteString]] ) {
        found( [[UIImage alloc] initWithContentsOfFile:[self pathOnDiskForName:[imageURL absoluteString]]] );
    } else {
        notFound();
    }
}

- (void) clearCache
{
	NSError *error;
	
	if ( ![[NSFileManager defaultManager] removeItemAtPath:self.localDirectory error:&error] )
		return;
	
	if ( ![[NSFileManager defaultManager] createDirectoryAtPath:self.localDirectory withIntermediateDirectories:NO attributes:nil error:&error] )
		return;
}

@end