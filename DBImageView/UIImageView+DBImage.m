//
//  UIImageView+DBImage.m
//  DBImageView
//
//  Created by iBo on 27/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "UIImageView+DBImage.h"
#import "DBImageRequest.h"
#import "DBImage.h"
#import "DBImageViewCache.h"

static BOOL DBImageShouldDownload = YES;
static NSString *const kRemoteImage = @"kRemoteImage";
static NSString *const kDBImageViewShouldStartDownload = @"kDBImageViewShouldStartDownload";

@interface UIImageView (DBInterface)
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation UIImageView (DBInterface)

- (void) setSpinner:(UIActivityIndicatorView *)spinner
{
    objc_setAssociatedObject(self, @"kSpinner", spinner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)spinner
{
    return objc_getAssociatedObject(self, @"kSpinner");
}

@end

@interface UIImageView (DBRequest)
@property (nonatomic, strong) DBImageRequest *currentRequest;
@end

@implementation UIImageView (DBRequest)

- (void) setCurrentRequest:(DBImageRequest *)currentRequest
{
    objc_setAssociatedObject(self, @"kCUrrentRequest", currentRequest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DBImageRequest *) currentRequest
{
    return objc_getAssociatedObject(self, @"kCurrentRequest");
}

@end

@implementation UIImageView (DBImage)

+ (void) triggerImageRequests:(BOOL)start
{
    if (start != DBImageShouldDownload) {
		DBImageShouldDownload = start;
		
		if (start)
			[[NSNotificationCenter defaultCenter] postNotificationName:kDBImageViewShouldStartDownload object:nil];
	}
}

- (DBImage *) remoteImage
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kRemoteImage));
}

- (void) setPlaceHolder:(UIImage *)placeHolder
{
    objc_setAssociatedObject(self, @"kPlaceHolder", placeHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *) placeHolder
{
    return objc_getAssociatedObject(self, @"kPlaceHolder");
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ( self.currentRequest ) {
        [self.currentRequest cancel];
    }
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        
        [self setContentMode:UIViewContentModeScaleAspectFill];
        [self setClipsToBounds:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldStartDownload:) name:kDBImageViewShouldStartDownload
                                                   object:nil];
    }
    return self;
}

- (void) setRemoteImage:(DBImage *)remoteImage
{
    if ( remoteImage != self.remoteImage ) {
        [self.currentRequest cancel];
		self.currentRequest = nil;

        objc_setAssociatedObject(self, (__bridge const void *)(kRemoteImage), remoteImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        self.image = nil;
        
        if ( self.placeHolder ) {
            self.image = self.placeHolder;
        }
        
        [self startDownloadImage];
    }
}

- (void) stopSpinner;
{
	[self.spinner stopAnimating];
	[self.spinner removeFromSuperview];
    self.spinner = nil;
}

- (void) shouldStartDownload:(NSNotification *)notification
{
    [self startDownloadImage];
}

- (void) startDownloadImage
{
    if ( self.currentRequest ) {
        return;
    }
    
    if ( !self.remoteImage ) {
        return;
    }
    
    [[DBImageViewCache cache] imageForURL:self.remoteImage.imageURL found:^(UIImage *image) {
        self.image = image;
    } notFound:^{
        if ( !DBImageShouldDownload ) {
            return;
        }
        
        if ( !self.spinner.superview ) {
            self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.spinner.center = (CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) };
            self.spinner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
            self.spinner.hidesWhenStopped = YES;
            [self addSubview:self.spinner];
        }
        
        [self.spinner startAnimating];
        
        self.currentRequest = self.remoteImage.imageRequest;
        
        [self.currentRequest downloadImageWithSuccess:^(UIImage *image, NSHTTPURLResponse *response) {
            [self stopSpinner];
            
            self.image = image;
            self.currentRequest = nil;
        } error:^(NSError *error) {
            [self stopSpinner];
            self.currentRequest = nil;
        }];
    }];
}

@end