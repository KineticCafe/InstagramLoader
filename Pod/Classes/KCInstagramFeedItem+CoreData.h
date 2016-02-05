//
//  KCInstagramFeedItem+CoreData.h
//  AldoMCEv1
//
//  Created by Michael Lan on 2016-02-05.
//  Copyright (c) 2016 Kineticcafe. All rights reserved.
//

#import "KCInstagramFeedItem.h"

@interface KCInstagramFeedItem (CoreData)

+ (KCInstagramFeedItem *) findOrCreateFeedItemWithID: (NSString *)itemID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (KCInstagramFeedItem *) existingFeedItemWithID: (NSString *)itemID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *) feedItemsEarlierThan: (NSDate *)time andSize:(NSUInteger)size inManagedObjecContext: (NSManagedObjectContext *)context;
@end
