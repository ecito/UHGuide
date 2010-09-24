//
//  Interest.h
//  UHCampusGuide
//
//  Created by CampusGuide on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface Interest : NSObject <MKAnnotation> {
	NSString *name;
	NSString *category;
	NSString *description;
	NSString *markerIcon;
	NSString *picture;
	NSString *URL;
	NSObject *data;

	float latitude;
	float longitude;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D location;


@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *description; 
@property (nonatomic, retain) NSString *markerIcon; 
@property (nonatomic, retain) NSString *picture; 
@property (nonatomic, retain) NSString *URL; 
@property (nonatomic, retain) NSObject *data;

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

-(id)initWithName:(NSString *)_name 
		 category:(NSString *)_category 
	  description:(NSString *)_description 
	   markerIcon:(NSString *)_markerIcon 
	      picture:(NSString *)_picture 
		 latitude:(float)_latitude 
		longitude:(float)_longitude
			  URL:(NSString *)_URL;

-(CLLocationCoordinate2D)coordinate;

@end
