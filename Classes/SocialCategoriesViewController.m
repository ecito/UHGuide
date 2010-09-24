//
//  SocialCategoriesViewController.m
//  UHGuide
//
//  Created by Andre Navarro on 8/30/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import "SocialCategoriesViewController.h"
#import "SocialCategoriesDataSource.h"


@implementation SocialCategoriesViewController

- (id)init {
  if (self = [super init]) {
    self.title = @"Social Media";
				
	}
  return self;
}

-(void)createModel {
	self.dataSource = [[[SocialCategoriesDataSource alloc] init] autorelease];
}

@end
