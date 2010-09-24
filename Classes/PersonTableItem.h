//
//  PersonTableItem.h
//  UHGuide
//
//  Created by Andre Navarro on 7/27/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import <Three20/Three20.h>
#import "Person.h"

@interface PersonTableItem : TTTableSubtitleItem {

	Person *person;
}

@property (nonatomic, retain) Person *person;

+ (id)itemWithPerson:(Person*)aPerson;

@end
