//
//  PersonTableItem.m
//  UHGuide
//
//  Created by Andre Navarro on 7/27/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import "PersonTableItem.h"


@implementation PersonTableItem

@synthesize person;

+ (id)itemWithPerson:(Person*)aPerson {
	PersonTableItem *item = [self itemWithText:[aPerson name] subtitle:[aPerson title] URL:@"uh://dummy"];
	item.person = [aPerson retain];
	return item;
}


@end
