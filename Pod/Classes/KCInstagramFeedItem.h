//
//  KCInstagramFeedItem.h
//  KCAldoInstagramViewer
//
//  Created by Austin Chen on 2015-06-11.
//  Copyright (c) 2015 Kinetic Cafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol KCInstagramFeedItem <NSObject>
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@end

@interface KCInstagramFeedItem : NSManagedObject <KCInstagramFeedItem>
@end
