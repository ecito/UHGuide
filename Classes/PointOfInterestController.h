//
//  PointOfInterestController.h
//  UHCampusGuide
//
//  Created by Kaleb Fulgham on 11/22/09.
//  Copyright 2009 Honey Bear Webdesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "JSON.h"
#import "Interest.h"
#import "InterestCategory.h"

@interface PointOfInterestController : NSObject <TTURLRequestDelegate, TTURLResponse>
{
	NSMutableArray *pointsOfInterest;
	NSMutableData *responseData;
	NSString *interestRequested;
	TTURLRequest *urlRequest;
}

@property(nonatomic,retain)NSMutableArray *pointsOfInterest;
@property(nonatomic,retain)TTURLRequest *urlRequest;
@property(nonatomic,retain)NSString *interestRequested;

- (id)init;

- (void)getAllPointsOfInterestFromCategory:(InterestCategory *)anInterestCategory;
- (void)getAllPointsOfInterestFromCategoryWith:(NSString *)name;
- (void)getAllPointsOfInterestFromCategory:(NSString *)aCategory withCache:(BOOL)cacheStatus;


@end
