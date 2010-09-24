//
//  InterestCategory.h
//  UHGuide
//
//  Created by Kaleb Fulgham on 12/12/09.
//  Copyright 2009 University of Houston. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InterestCategory : NSObject {
	/*
	 "name":"Parking",
	 "created_at":"2009-12-04T08:33:01Z",
	 "default_marker":"parking.png",
	 "updated_at":"2009-12-04T08:33:01Z",
	 "id":1,
	 "description":"Live parking status",
	 "source":"dynamic"
	 */
	
	NSInteger category_id;
	NSString *name;
	NSString *default_marker;
	NSString *description;
	BOOL caching;
}

@property (nonatomic, assign) NSInteger category_id; 
@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSString *default_marker;
@property (nonatomic, retain) NSString *description; 
@property (nonatomic, assign) BOOL caching; 

-(id)initWithName:(NSString *)_name 
		 categoryId:(NSInteger)_category_id
	  defaultMarker:(NSString *)_default_marker 
	   description:(NSString *)_description 
	      caching:(BOOL)_caching;


@end
