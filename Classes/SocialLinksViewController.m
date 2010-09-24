//
//  SocialLinksViewController.m
//  UHGuide
//
//  Created by Andre Navarro on 8/30/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import "SocialLinksViewController.h"
#import "SocialLinksDataSource.h"

@implementation SocialLinksViewController

@synthesize	category = _category;

- (id)initWithCategory:(NSString *)aCategory {
  if (self = [super init]) {
    self.title = @"Links";
		self.category = aCategory;
		
    //self.tableViewStyle = UITableViewStyleGrouped;
		self.variableHeightRows = YES;
				
	}
  return self;
}

-(void)createModel {
	self.dataSource = [[[SocialLinksDataSource alloc] initWithCategory:_category] autorelease];
}

@end
