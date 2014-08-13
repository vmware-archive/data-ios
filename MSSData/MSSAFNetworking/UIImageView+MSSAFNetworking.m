// UIImageView+MSSAFNetworking.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import "UIImageView+MSSAFNetworking.h"

@interface MSSAFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

#pragma mark -

static char kMSSAFImageRequestOperationObjectKey;

@interface UIImageView (_MSSAFNetworking)
@property (readwrite, nonatomic, strong, setter = MSSAF_setImageRequestOperation:) MSSAFImageRequestOperation *MSSAF_imageRequestOperation;
@end

@implementation UIImageView (_MSSAFNetworking)
@dynamic MSSAF_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (MSSAFNetworking)

- (MSSAFHTTPRequestOperation *)MSSAF_imageRequestOperation {
    return (MSSAFHTTPRequestOperation *)objc_getAssociatedObject(self, &kMSSAFImageRequestOperationObjectKey);
}

- (void)MSSAF_setImageRequestOperation:(MSSAFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kMSSAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)MSSAF_sharedImageRequestOperationQueue {
    static NSOperationQueue *_MSSAF_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MSSAF_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_MSSAF_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });

    return _MSSAF_imageRequestOperationQueue;
}

+ (MSSAFImageCache *)MSSAF_sharedImageCache {
    static MSSAFImageCache *_MSSAF_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _MSSAF_imageCache = [[MSSAFImageCache alloc] init];
    });

    return _MSSAF_imageCache;
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];

    UIImage *cachedImage = [[[self class] MSSAF_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        self.MSSAF_imageRequestOperation = nil;

        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }

        MSSAFImageRequestOperation *requestOperation = [[MSSAFImageRequestOperation alloc] initWithRequest:urlRequest];
		
#ifdef _MSSAFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_
		requestOperation.allowsInvalidSSLCertificate = YES;
#endif
		
        [requestOperation setCompletionBlockWithSuccess:^(MSSAFHTTPRequestOperation *operation, id responseObject) {
            if ([urlRequest isEqual:[self.MSSAF_imageRequestOperation request]]) {
                if (self.MSSAF_imageRequestOperation == operation) {
                    self.MSSAF_imageRequestOperation = nil;
                }

                if (success) {
                    success(operation.request, operation.response, responseObject);
                } else if (responseObject) {
                    self.image = responseObject;
                }
            }

            [[[self class] MSSAF_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(MSSAFHTTPRequestOperation *operation, NSError *error) {
            if ([urlRequest isEqual:[self.MSSAF_imageRequestOperation request]]) {
                if (self.MSSAF_imageRequestOperation == operation) {
                    self.MSSAF_imageRequestOperation = nil;
                }

                if (failure) {
                    failure(operation.request, operation.response, error);
                }
            }
        }];

        self.MSSAF_imageRequestOperation = requestOperation;

        [[[self class] MSSAF_sharedImageRequestOperationQueue] addOperation:self.MSSAF_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.MSSAF_imageRequestOperation cancel];
    self.MSSAF_imageRequestOperation = nil;
}

@end

#pragma mark -

static inline NSString * MSSAFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation MSSAFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }

	return [self objectForKey:MSSAFImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:MSSAFImageCacheKeyFromURLRequest(request)];
    }
}

@end

#endif
