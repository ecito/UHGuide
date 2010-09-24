//
//  Building.h
//  UHGuide
//
//  Created by Andre Navarro on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Building : NSObject <MKAnnotation> {
	NSString *name;
	NSString *code;
	NSInteger number;

	float latitude;
	float longitude;

}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D location;

@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSString *code; 
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

-(id)initWithName:(NSString *)_name code:(NSString *)_code number:(NSInteger)_number latitude:(float)_latitude longitude:(float)_longitude;



@end
