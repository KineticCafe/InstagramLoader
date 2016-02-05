//
//  KCInstagramFeedResponseProcessor.m
//  AldoMCEv1
//
//  Created by Michael Lan on 2016-02-05.
//  Copyright (c) 2016 Kineticcafe. All rights reserved.
//

#import "KCInstagramFeedResponseProcessor.h"
#import "KCInstagramFeedItem.h"
#import "KCInstagramFeedItem+CoreData.h"
#import <UIKit/UIKit.h>

#define kFeedKeyPagination  @"pagination"
#define kFeedKeyNextMaxId   @"next_max_id"
#define kFeedKeyData        @"data"
#define kFeedKeyId          @"id"
#define kFeedKeyImages      @"images"
#define kFeedKeyStdRes      @"standard_resolution"
#define kFeedKeyUrl         @"url"
#define kFeedKeyCaption     @"caption"
#define kFeedKeyCreatedTime @"created_time"
#define kFeedKeyText        @"text"

@interface KCInstagramFeedResponseProcessor () {
    NSDictionary *_rootDictionary;
}

@end

@implementation KCInstagramFeedResponseProcessor

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self != nil) {
        _rootDictionary = dict;
    }
    return self;
}

- (NSArray *)processInstagramFeedAndCachedImageObjectsInContext:(NSManagedObjectContext *)context {
    NSMutableArray *imageUrls = [[NSMutableArray alloc] init];
    NSMutableArray *feedItems = [[NSMutableArray alloc] init];
    NSArray *data = [_rootDictionary objectForKey:kFeedKeyData];
    for (NSDictionary *datum in data) {
        NSString *datumID = [datum objectForKey:kFeedKeyId];
        
        KCInstagramFeedItem *feedItem = [KCInstagramFeedItem findOrCreateFeedItemWithID:datumID inManagedObjectContext:context];
        if (feedItem == nil) {
            NSLog(@"Error creating feed item with ID %@", datumID);
            continue;
        }
        feedItem.itemID = datumID;
        
        // pick out image url
        NSDictionary *images = [datum isKindOfClass:NSNull.class] ? nil : [datum objectForKey:kFeedKeyImages];
        NSDictionary *stardardResolution = [images isKindOfClass:NSNull.class] ? nil : [images objectForKey:kFeedKeyStdRes];
        NSString *imageUrl = [stardardResolution isKindOfClass:NSNull.class] ? nil : [stardardResolution objectForKey:kFeedKeyUrl];
        if (imageUrl != nil) {
            feedItem.imageUrl = imageUrl;
            [imageUrls addObject:imageUrl];
        }
        
        // pick out caption
        NSDictionary *caption = [datum objectForKey:kFeedKeyCaption];
        
        // pick out created time
        NSString *createdTime = [caption objectForKey:kFeedKeyCreatedTime];
        NSNumber *createdTimeNumber = [[NSNumberFormatter new] numberFromString:createdTime];
        NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:createdTimeNumber.doubleValue];
        feedItem.created = createdDate;
        
        // pick out created time
        NSString *text = [caption objectForKey:kFeedKeyText];
        feedItem.title = text;
        feedItem.type = @0;
        
        [feedItems addObject:feedItem];
    }
    
    if ([context hasChanges]) {
        NSError *error = nil;
        if ([context save:&error] == NO) {
            NSLog(@"KCInstagramFeedResponseProcessor: Error saving instagram feed items: %@", error);
        }
    }
    
    return [NSArray arrayWithArray:imageUrls];
}

- (NSString *)processInstagramFeedForNextBatchId {
    NSDictionary *pagination = [_rootDictionary objectForKey:kFeedKeyPagination];
    NSString *nextMaxId = [pagination objectForKey:kFeedKeyNextMaxId];
    return nextMaxId;
}

@end

