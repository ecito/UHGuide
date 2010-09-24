//
//  InterestCategoryController.h
//  UHGuide
//
//  Created by Kaleb Fulgham on 12/10/09.
//  Copyright 2009 University of Houston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "JSON.h"
#import "InterestCategory.h"

@interface InterestCategoryController : NSObject <TTURLRequestDelegate, TTURLResponse>
{
	NSMutableArray *categories;
	NSMutableData *responseData;
	
	TTURLRequest *urlRequest;
}

@property(nonatomic,retain)NSMutableArray *categories;
@property(nonatomic,retain)TTURLRequest *urlRequest;

- (id)init;
- (void)getAllCategories;

@end
