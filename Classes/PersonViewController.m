//
//  PersonViewController.m
//  UHGuide
//
//  Created by Andre Navarro on 7/26/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import "PersonViewController.h"


@implementation PersonViewController

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query { 
	if (self = [super init]) {
		
		person = [query objectForKey:@"person"];
		self.title = [person name];
		self.displayedPerson = [person record];
		self.allowsAddingToAddressBook = YES;
		
	}
	return self;
	
}


@end
