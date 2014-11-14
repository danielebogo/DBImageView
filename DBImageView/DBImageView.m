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

@property (nonatomic, strong) DBImage *remoteImage;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation DBImageView

+ (void) clearCache {
    [[DBImageViewCache cache] clearCache];
}

+ (void) triggerImageRequests:(BOOL)start {
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
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        [self addSubview:self.spinner];
        
        self.spinner.center = (CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) };
        
        [self config];
    }
    return self;
}

- (id) init {
    self = [super init];
    if ( self ) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageView];
        [self addSubview:self.spinner];
        [self config];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|"
                                                                     options:0 metrics:nil views:@{ @"_imageView":_imageView }]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|"
                                                                     options:0 metrics:nil views:@{ @"_imageView":_imageView }]];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_currentRequest cancel];
}

#pragma mark - Override

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    _imageView.frame = self.bounds;
    _spinner.center = (CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) };
}

- (void) setClipsToBounds:(BOOL)clipsToBounds {
    [super setClipsToBounds:clipsToBounds];
    [_imageView setClipsToBounds:clipsToBounds];
}

- (void) setContentMode:(UIViewContentMode)contentMode {
    _imageView.contentMode = contentMode;
}

- (void) setImage:(UIImage *)image {
    _imageView.image = image;
}

- (void) setPlaceHolder:(UIImage *)placeHolder {
    if ( ![placeHolder isEqual:_placeHolder] ) {
        _placeHolder = placeHolder;
        _imageView.image = placeHolder;
    }
}

- (void) setImageViewcontentMode:(UIViewContentMode)imageViewcontentMode {
    _imageView.contentMode = imageViewcontentMode;
}

- (void) setRemoteImage:(DBImage *)remoteImage {
    if ( remoteImage != _remoteImage ) {
        [_currentRequest cancel];
        _currentRequest = nil;
        
        _remoteImage = remoteImage;
        
        if ( _placeHolder ) {
            _imageView.image = _placeHolder;
        } else {
            _imageView.image = nil;
        }
        
        [self startDownloadImage];
    }
}

- (UIActivityIndicatorView *) spinner {
    if ( !_spinner ) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.translatesAutoresizingMaskIntoConstraints = NO;
        _spinner.hidesWhenStopped = YES;
        _spinner.hidden = YES;
    }
    return _spinner;
}

#pragma mark - Config

- (void) config {
    self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
    
    [self setContentMode:UIViewContentModeScaleAspectFill];
    [self setClipsToBounds:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldStartDownload:) name:kDBImageViewShouldStartDownload object:nil];
}

#pragma mark - Methods

- (void) stopSpinner; {
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
}

- (void) shouldStartDownload:(NSNotification *)notification {
    [self startDownloadImage];
}

- (void) startDownloadImage {
    if ( _currentRequest ) {
        return;
    }
    
    if ( !_remoteImage ) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[DBImageViewCache cache] imageForURL:_remoteImage.imageURL found:^(UIImage *image) {
        typeof(self) blockSelf = weakSelf;
        blockSelf->_imageView.image = image;
    } notFound:^{
        if ( !DBImageShouldDownload ) {
            return;
        }
        
        [weakSelf.spinner startAnimating];
        weakSelf.spinner.hidden = NO;
        
        typeof(self) blockSelf = weakSelf;

        blockSelf->_currentRequest = _remoteImage.imageRequest;
        [blockSelf->_currentRequest downloadImageWithSuccess:^(UIImage *image, NSHTTPURLResponse *response) {
            [weakSelf stopSpinner];
            blockSelf->_imageView.image = image;
            blockSelf->_currentRequest = nil;
            blockSelf->_imageWithPath = nil;
        } error:^(NSError *error) {
            [weakSelf stopSpinner];
            blockSelf->_currentRequest = nil;
            blockSelf->_imageWithPath = nil;
        }];
    }];
}

- (void) setImageWithPath:(NSString *)imageWithPath {
    if ( [_imageWithPath isEqualToString:imageWithPath] ) {
        return;
    }
    
    _imageWithPath = imageWithPath;
    [self setRemoteImage:[DBImage imageWithPath:_imageWithPath]];
}

@end