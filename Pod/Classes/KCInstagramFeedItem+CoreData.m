//
//  KCInstagramFeedItem+CoreData.m
//  AldoMCEv1
//
//  Created by Michael Lan on 2016-02-05.
//  Copyright (c) 2016 Kineticcafe. All rights reserved.
//

#import "KCInstagramFeedItem+CoreData.h"

@implementation KCInstagramFeedItem (CoreData)

+ (KCInstagramFeedItem *) findOrCreateFeedItemWithID: (NSString *)itemID inManagedObjectContext:(NSManagedObjectContext *)context {
    if ( itemID == nil ) {
        NSLog( @"%@: itemID is nil", NSStringFromSelector(_cmd) );
        return nil;
    }
    
    KCInstagramFeedItem *feedItem = [[self class] existingFeedItemWithID:itemID inManagedObjectContext:context];
    if( feedItem != nil )
    {
        return feedItem;
    }
    
    feedItem = [NSEntityDescription insertNewObjectForEntityForName: @"KCInstagramFeedItem"
                                            inManagedObjectContext:context];
    feedItem.itemID = itemID;
    feedItem.type = 0;
    
    return feedItem;
}

+ (KCInstagramFeedItem *) existingFeedItemWithID: (NSString *)itemID inManagedObjectContext:(NSManagedObjectContext *)context {
    if ( itemID == nil ) {
        NSLog( @"%@: itemID is nil", NSStringFromSelector(_cmd) );
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"itemID == %@", itemID ];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity: [NSEntityDescription entityForName: @"KCInstagramFeedItem" inManagedObjectContext: context]];
    [request setPredicate: predicate];
    [request setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest: request error: &error];
    KCInstagramFeedItem * feedItem = [results lastObject];
    
    if( error != nil ) {
        NSLog( @"Error getting instagram feed item with itemID %@: %@:%@", itemID, error, [error userInfo] );
    }
    
    return feedItem;
}

+ (NSArray *) feedItemsEarlierThan: (NSDate *)time andSize:(NSUInteger)size inManagedObjecContext: (NSManagedObjectContext *)context{
    if ( time == nil ) {
        NSLog( @"%@: time is nil", NSStringFromSelector(_cmd) );
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"created < %@", time ];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity: [NSEntityDescription entityForName: @"KCInstagramFeedItem" inManagedObjectContext: context]];
    [request setPredicate: predicate];
    [request setFetchLimit:size];
    // add sorting
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest: request error: &error];
    
    if( error != nil ) {
        NSLog( @"Error getting instagram feed items ealier than time %@: %@:%@", time, error, [error userInfo] );
    }
    
    return results;
}

@end
