//
//  Interest.m
//  UHCampusGuide
//
//  Created by CampusGuide on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Interest.h"

@implementation Interest
@synthesize name, category, description, markerIcon, picture, latitude, longitude, URL;

-(id)initWithName:(NSString *)_name 
		 category:(NSString *)_category 
	  description:(NSString *)_description 
	   markerIcon:(NSString *)_markerIcon 
	      picture:(NSString *)_picture 
		 latitude:(float)_latitude 
		longitude:(float)_longitude
			  URL:(NSString *)_URL
{
	self.name = _name; 
	self.category = _category;
	self.description = _description;
	self.markerIcon = _markerIcon;
	self.picture = _picture;
	self.latitude = _latitude;
	self.longitude = _longitude;
	self.URL = _URL;
	
	return self; 
} 

- (void)dealloc
{
    [super dealloc];
}

-(NSString*)title {
	return name;
}

-(NSString*)subtitle {
	return description;
}

-(CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coor;
	coor.latitude = latitude;
	coor.longitude = longitude;
	
	return coor;
}


@dynamic data;

@end
