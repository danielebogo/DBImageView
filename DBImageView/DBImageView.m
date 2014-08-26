//
//  DBImageView.m
//  DBImageView
//
//  Created by iBo on 25/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "DBImageView.h"
#import "DBImageRequest.h"
#import "DBImage.h"
#import "DBImageViewCache.h"

static BOOL DBImageShouldDownload = YES;
static NSString *const kDBImageViewShouldStartDownload = @"kDBImageViewShouldStartDownload";

@interface DBImageView () {
    DBImageRequest *_currentRequest;
    UIImageView *_imageView;
    UIActivityIndicatorView *_spinner;
}

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation DBImageView

+ (void) triggerImageRequests:(BOOL)start
{
    if (start != DBImageShouldDownload) {
		DBImageShouldDownload = start;
		
		if (start)
			[[NSNotificationCenter defaultCenter] postNotificationName:kDBImageViewShouldStartDownload object:nil];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];

        [self setContentMode:UIViewContentModeScaleAspectFill];
        [self setClipsToBounds:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldStartDownload:) name:kDBImageViewShouldStartDownload
                                                   object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_currentRequest cancel];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _imageView.frame = self.bounds;
    _spinner.center = (CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) };
}

- (void) setClipsToBounds:(BOOL)clipsToBounds
{
    [super setClipsToBounds:clipsToBounds];
    [_imageView setClipsToBounds:clipsToBounds];
}

- (void) setContentMode:(UIViewContentMode)contentMode
{
    _imageView.contentMode = contentMode;
}

- (void) stopSpinner;
{
	[self.spinner stopAnimating];
	[self.spinner removeFromSuperview];
}

- (void) shouldStartDownload:(NSNotification *)notification
{
    [self startDownloadImage];
}

- (void) startDownloadImage
{
    if ( _currentRequest ) {
        return;
    }
    
    if ( !_remoteImage ) {
        return;
    }
    
    [[DBImageViewCache cache] imageForURL:_remoteImage.imageURL found:^(UIImage *image) {
        _imageView.image = image;
    } notFound:^{
        if ( !DBImageShouldDownload ) {
            return;
        }
        
        if ( !self.spinner.superview ) {
            [self addSubview:self.spinner];
        }
        
        [self.spinner startAnimating];
        
        _currentRequest = _remoteImage.imageRequest;
        
        [_currentRequest downloadImageWithSuccess:^(UIImage *image, NSHTTPURLResponse *response) {
            [self stopSpinner];
            
            _imageView.image = image;
            _currentRequest = nil;
        } error:^(NSError *error) {
            [self stopSpinner];
            _currentRequest = nil;
        }];
    }];
}

#pragma mark - Properties

- (void) setRemoteImage:(DBImage *)remoteImage
{
    if ( remoteImage != _remoteImage ) {
        [_currentRequest cancel];
		_currentRequest = nil;
        
        _remoteImage = remoteImage;
        
        _imageView.image = nil;
        
        if ( _placeHolder ) {
            _imageView.image = _placeHolder;
        }
        
        [self startDownloadImage];
    }
}

- (UIActivityIndicatorView *) spinner
{
    if ( !_spinner ) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.center = (CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) };
		_spinner.hidesWhenStopped = YES;
    }
    return _spinner;
}

- (void) setImage:(UIImage *)image
{
    _imageView.image = image;
}

@end