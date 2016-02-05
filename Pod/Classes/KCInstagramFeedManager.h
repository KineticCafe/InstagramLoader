//
//  KCInstagramFeedManager.h
//  AldoMCEv1
//
//  Created by Michael Lan on 2016-02-05.
//  Copyright (c) 2016 Kineticcafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCInstagramFeedManager : NSObject
@property (nonatomic, retain) NSString * instagramUserID;
@property (nonatomic, retain) NSString * instagramClientID;

+ (KCInstagramFeedManager *) sharedManager;
+ (NSUInteger) defaultFetchSize;

- (void) fetchLatestFeedItemsInContext:(NSManagedObjectContext*)context;
- (void) fetchMoreFeedItemsInContext:(NSManagedObjectContext*)context;

- (void) resetFetch;

extern NSString * const KCInstagramFeedManagerGetFeedSucceeded;
extern NSString * const KCInstagramFeedManagerGetFeedFailed;

@end
