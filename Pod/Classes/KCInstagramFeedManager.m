//
//  KCInstagramFeedManager.m
//  AldoMCEv1
//
//  Created by Michael Lan on 2016-02-05.
//  Copyright (c) 2016 Kineticcafe. All rights reserved.
//

#import "KCInstagramFeedManager.h"
#import "AFHTTPRequestOperation.h"
#import "KCInstagramFeedResponseProcessor.h"
#import "KCInstagramFeedItem.h"

#define kInstagramFeedItemsBatchSize 5

NSString * const KCInstagramFeedManagerGetFeedSucceeded = @"KCInstagramFeedManagerGetFeedSucceeded";
NSString * const KCInstagramFeedManagerGetFeedFailed    = @"KCInstagramFeedManagerGetFeedFailed";

@interface KCInstagramFeedManager () {
    NSOperationQueue *_asyncNetworkOperationQ;
    BOOL _fetchingInProgress;
    NSString *_nextBatchId;
}
@end


@implementation KCInstagramFeedManager

static KCInstagramFeedManager *_manager;

+ (KCInstagramFeedManager *) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KCInstagramFeedManager alloc] init];
    });
    return _manager;
}

+ (NSUInteger) defaultFetchSize {
    return kInstagramFeedItemsBatchSize;
}

- (id)init {
    self = [super init];
    if (self) {
        _asyncNetworkOperationQ = [[NSOperationQueue alloc] init];
        _asyncNetworkOperationQ.name = @"com.kineticcafe.InstagramFeed.asyncQ";
        _asyncNetworkOperationQ.maxConcurrentOperationCount = 1;
        
        _nextBatchId = nil;
    }
    return self;
}

- (void) fetchLatestFeedItemsInContext:(NSManagedObjectContext*)context {
    [self fetchFeed:nil batchSize:kInstagramFeedItemsBatchSize context:context];
}

- (void) fetchMoreFeedItemsInContext:(NSManagedObjectContext*)context {
    [self fetchFeed:_nextBatchId batchSize:kInstagramFeedItemsBatchSize context:context];
}

- (void) fetchFeed:(NSString *)startingID batchSize:(NSInteger)size context:(NSManagedObjectContext *)context{
    if (!self.instagramUserID || !self.instagramClientID) {
        NSLog( @"%@: instagram user ID or client ID is nil.", NSStringFromSelector(_cmd) );
    }
    
    NSString *nextBatch = @"";
    if (startingID != nil) {
        nextBatch = [NSString stringWithFormat:@"&max_id=%@", startingID];
    }
    NSString *queryString = [NSString stringWithFormat:@"count=%d%@&client_id=%@", kInstagramFeedItemsBatchSize, nextBatch, self.instagramClientID];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent?%@", self.instagramUserID, queryString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                KCInstagramFeedResponseProcessor *processor = [[KCInstagramFeedResponseProcessor alloc] initWithJSONDictionary:responseObject];
                [processor processInstagramFeedAndCachedImageObjectsInContext:context];
                
                _nextBatchId = [processor processInstagramFeedForNextBatchId];
                
                NSDictionary *userInfo = nil;
                if (_nextBatchId == nil || _nextBatchId == (id)[NSNull null]) {
                    userInfo = @{@"isEndReached": @(YES)};
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KCInstagramFeedManagerGetFeedSucceeded object:nil userInfo:userInfo];
                });
            } else {
                NSLog( @"%@: Failed for request %@, responseObject is nil.", NSStringFromSelector(_cmd), operation.request);
                [[NSNotificationCenter defaultCenter] postNotificationName:KCInstagramFeedManagerGetFeedFailed object:nil userInfo:nil];
                _fetchingInProgress = NO;
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed for request %@ with error %@", operation.request, error);
        _fetchingInProgress = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KCInstagramFeedManagerGetFeedFailed object:nil userInfo:nil];
        });
    }];
    
    _fetchingInProgress = YES;
    [_asyncNetworkOperationQ addOperation:operation];
}

- (void) resetFetch {
    _nextBatchId = nil;
}

@end
