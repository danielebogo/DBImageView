//
//  DBImageRequest.m
//  DBImageView
//
//  Created by iBo on 25/08/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "DBImageRequest.h"
#import "DBImageViewCache.h"

@interface DBImageRequest () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableData* receivedData;
@property (nonatomic, assign) BOOL ended;
@property(copy, nonatomic) DBRequestSuccessHandler successHandler;
@property(copy, nonatomic) DBRequestErrorHandler errorHandler;
@end

@implementation DBImageRequest

- (id) initWithURLRequest:(NSURLRequest*)request
{
    self = [super init];
    
    if ( self ) {
        _request = request;
    }
    
    return self;
}

- (void) dealloc;
{
	[_connection cancel];
}

- (void) downloadImageWithSuccess:(DBRequestSuccessHandler)success error:(DBRequestErrorHandler)error
{
    _successHandler = success;
	_errorHandler = error;
	_receivedData = [NSMutableData data];
	_connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}

- (void) requestDidEnd
{
    [_connection cancel];
    _connection = nil;
    
	_successHandler = nil;
	_errorHandler = nil;
	_response = nil;
    _receivedData = nil;
}

- (void) cancel
{
    [self endWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void) endWithError:(NSError *)error
{
    if ( _ended ) {
        return;
    }
    
    _ended = YES;
    
    if ( error ) {
        if (_errorHandler) {
            (_errorHandler)(error);
        }
    } else {
        if ( _successHandler ) {
            [[DBImageViewCache cache] saveImageFromName:_request.URL.absoluteString data:_receivedData];
            _successHandler( [[UIImage alloc] initWithData:_receivedData], _response);
        }
    }
    
    [self requestDidEnd];
}

#pragma mark - NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self endWithError:nil];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self endWithError:error];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = (NSHTTPURLResponse *)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

@end