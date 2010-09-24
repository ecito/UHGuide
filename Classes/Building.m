//
//  Building.m
//  ProgrammaticMap
//
//  Created by Andre Navarro on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Building.h"

@implementation Building
@synthesize name, code, number, latitude, longitude;

-(id)initWithName:(NSString *)_name code:(NSString *)_code number:(NSInteger)_number latitude:(float)_latitude longitude:(float)_longitude
{
	self.name = _name; 
	self.code = _code;
	self.number = _number;
	self.latitude = _latitude;
	self.longitude = _longitude;
	
	return self; 
} 

- (void)dealloc
{
	self.name = nil;
	self.code = nil;
    [super dealloc];
}

-(NSString*)title {
	return code;
}

-(NSString*)subtitle {
	return name;
}

-(CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coor;
	coor.latitude = latitude;
	coor.longitude = longitude;
	
	return coor;
}

@end
