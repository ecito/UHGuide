//
//  WeatherController.h
//  UHCampusGuide
//
//  Created by CampusGuide (Kaleb Fulgham) on 12/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "JSON.h"
#import "P31.h"

@protocol WeatherControllerDelegate <NSObject>

-(void)didReceiveWeatherData:(NSArray*)weatherData;

@end

@interface WeatherController : NSObject
{
	NSMutableArray *weatherData;
	NSMutableData *responseData;
	
	NSInteger currentTemperature;
	P31LoadingView *loadingView;
	
	id<WeatherControllerDelegate> delegate;
}

@property(nonatomic,retain)NSMutableArray *weatherData;
@property(nonatomic,assign)NSInteger currentTemperature;
@property(nonatomic,retain)P31LoadingView *loadingView;
@property(nonatomic,assign)id delegate;

- (id)init;
- (void)getWeather;

@end
