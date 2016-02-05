//
//  KCInstagramFeedResponseProcessor.h
//  AldoMCEv1
//
//  Created by Michael Lan on 2016-02-05.
//  Copyright (c) 2016 Kineticcafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCInstagramFeedResponseProcessor : NSObject

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;

- (NSArray *)processInstagramFeedAndCachedImageObjectsInContext:(NSManagedObjectContext *)context;
- (NSString *)processInstagramFeedForNextBatchId;
@end
