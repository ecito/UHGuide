//
//  WeatherViewsController.m
//  UHCampusGuide
//
//  Created by UHCampusGuide on 12/3/09.
//  Copyright 2009 UNIVERSITY OF HOUSTON. All rights reserved.
//

#import "WeatherViewsController.h"
#import "NetworkUtility.h"
#import "FlurryAPI.h"

@implementation WeatherViewsController

@synthesize currentTemp, todayHighTemp, todayLowTemp, tomorrowHighTemp, tomorrowLowTemp, todayDay, tomorrowDay, lastUpdated;
@synthesize todayPic, tomorrowPic;
@synthesize days, weatherController, badgeDictionary, currentTemperature;

- (id)init
{
	weatherController = [[WeatherController alloc] init];
	
	badgeDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
	[badgeDictionary setObject:@"uh://weather" forKey:@"url"];

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//[[Beacon shared] startSubBeaconWithName:@"weather: at weatherView" timeSession:YES];
	[FlurryAPI logEvent:@"weather: at weatherView" timed:YES];

	self.title = @"Weather";

	NetworkUtility *nUtil = [NetworkUtility sharedInstance]; 
	if ([nUtil startNetwork] == NotReachable) {
		UIAlertView *noInternet = 
			[[[UIAlertView alloc] initWithTitle:@"Internet Connection Unavailable"
									message:@"Sorry, we were unable to load Weather information because an Internet connection could not be found."
								   delegate:self cancelButtonTitle:@"Ok" 
						  otherButtonTitles:nil, nil] autorelease];
		
		[noInternet show];
	} 
	else
	{
		TTImageView *imageView = [[TTImageView alloc] initWithFrame:CGRectMake(26, 214, 264, 198)];
		imageView.urlPath = [NSString stringWithFormat:@"http://images.webcams.travel/webcam/1239991620.jpg?%d",
												 (long)[[NSDate date] timeIntervalSince1970]];
		//imageView.tag = 999;
		[self.view addSubview:imageView];

		//http://wwc.instacam.com/instacamimg4/huton/12102009/121020091900_l.jpg

		
		[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateWeatherViewWith:) 
												 name:@"LoadedWeatherData" object:nil];
		
		// Request weather
		[weatherController getWeather];
	}
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([actionSheet.title isEqualToString:@"Internet Connection Unavailable"])
	{
		//OK button pressed, return to launcher
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void)updateWeatherViewWith:(NSNotification *)notification
{
	// Loop through each entry in the dictionary...
	for (NSDictionary *day in weatherController.weatherData)
	{
		NSString *icon;
		NSString *iconURL;
		if([todayDay.text length] == 0)
		{
			currentTemp.text = [NSString stringWithFormat:@"%.0f", [[[day objectForKey:@"current"] objectForKey:@"fahrenheit"] floatValue]];
			todayDay.text = [[day objectForKey:@"date"] objectForKey:@"weekday"];
			todayHighTemp.text = [[day objectForKey:@"high"] objectForKey:@"fahrenheit"];
			todayLowTemp.text = [[day objectForKey:@"low"] objectForKey:@"fahrenheit"];
			lastUpdated.text = [day objectForKey:@"observation_time"];
			icon = [day objectForKey:@"icon"];
			iconURL = [NSString stringWithFormat:@"http://icons-pe.wxug.com/i/c/a/%@.gif", icon];	
			todayPic.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:iconURL]]];
			
			// Send badge update
			[badgeDictionary setObject:currentTemp.text forKey:@"number"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBadge" object:badgeDictionary];

		}
		else if([tomorrowDay.text length] == 0)
		{
			tomorrowDay.text = [[day objectForKey:@"date"] objectForKey:@"weekday"];
			tomorrowHighTemp.text = [[day objectForKey:@"high"] objectForKey:@"fahrenheit"];
			tomorrowLowTemp.text = [[day objectForKey:@"low"] objectForKey:@"fahrenheit"];
			icon = [day objectForKey:@"icon"];
			iconURL = [NSString stringWithFormat:@"http://icons-pe.wxug.com/i/c/a/%@.gif", icon];	
			tomorrowPic.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:iconURL]]];
		}
	} 
}

- (void)dealloc 
{
	//[[Beacon shared] endSubBeaconWithName:@"weather: at weatherView"];
	[FlurryAPI endTimedEvent:@"weather: at weatherView"];

	[days release];
	[badgeDictionary release];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
										 name:@"LoadedWeatherData"
										 object:nil];
	
	[super dealloc];
}	

@end
