//
//  InterestCategory.m
//  UHGuide
//
//  Created by Kaleb Fulgham on 12/12/09.
//  Copyright 2009 University of Houston. All rights reserved.
//

#import "InterestCategory.h"


@implementation InterestCategory

@synthesize name, category_id, description, default_marker, caching;

-(id)initWithName:(NSString *)_name 
	   categoryId:(NSInteger)_category_id
	defaultMarker:(NSString *)_default_marker 
	  description:(NSString *)_description 
		  caching:(BOOL)_caching
{
	self.name = _name; 
	self.category_id = _category_id;
	self.description = _description;
	self.default_marker = _default_marker;
	self.caching = _caching;
	
	return self; 
}

- (void)dealloc
{
	self.name = nil; 
	self.description = nil;
	self.default_marker = nil;
    [super dealloc];
}

@end