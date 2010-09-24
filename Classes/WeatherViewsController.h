//
//  WeatherViewsController.h
//  UHCampusGuide
//
//  Created by Hussain Abbasi on 12/3/09.
//  Copyright 2009 UNIVERSITY OF HOUSTON. All rights reserved.
//

#import <Three20/Three20.h>
#import "JSON.h"
#import "WeatherController.h"
@protocol WeatherControllerDelegate;

@interface WeatherViewsController : UIViewController <UIAlertViewDelegate, WeatherControllerDelegate>
{
	NSMutableArray * days;
	NSInteger currentTemperature;
	
	UILabel *currentTemp;
	UILabel *todayHighTemp;
	UILabel *todayLowTemp;
	UILabel *tomorrowHighTemp;
	UILabel *tomorrowLowTemp;
	UILabel *todayDay;
	UILabel *tomorrowDay;
	UILabel *lastUpdated;
	
	UIImageView *todayPic;
	UIImageView *tomorrowPic;
	
	NSMutableDictionary *badgeDictionary;
	
	WeatherController *weatherController;
}

@property (nonatomic, retain) NSMutableArray *days;
@property (nonatomic, assign) NSInteger currentTemperature;

@property (nonatomic, assign) IBOutlet UILabel *currentTemp;
@property (nonatomic, assign) IBOutlet UILabel *todayHighTemp;
@property (nonatomic, assign) IBOutlet UILabel *todayLowTemp;
@property (nonatomic, assign) IBOutlet UILabel *tomorrowHighTemp;
@property (nonatomic, assign) IBOutlet UILabel *tomorrowLowTemp;
@property (nonatomic, assign) IBOutlet UILabel *todayDay;
@property (nonatomic, assign) IBOutlet UILabel *tomorrowDay;
@property (nonatomic, assign) IBOutlet UILabel *lastUpdated;

@property (nonatomic, retain) IBOutlet UIImageView *todayPic;
@property (nonatomic, retain) IBOutlet UIImageView *tomorrowPic;

@property (nonatomic, retain) NSMutableDictionary *badgeDictionary;

@property (nonatomic, retain) WeatherController *weatherController;


@end
