//
//  WeatherController.m
//  UHCampusGuide
//
//  Created by CampusGuide on 12/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeatherController.h"


@implementation WeatherController

@synthesize weatherData, currentTemperature;
@synthesize loadingView;

- (id)init
{
	responseData = [[NSMutableData data] retain];
	weatherData = [[NSMutableArray alloc] init];
	currentTemperature = 0;

	return self;
}

- (void)getWeather
{	
	TTNetworkRequestStarted();
	loadingView = [P31LoadingView loadingViewShowWithLoadingMessage];
	
	NSLog(@"Getting weather data!");
	// URL to obtain the weather data
	NSString *urlString = @"http://uhcamp.us.to/weathers/current";
	
	// Create NSURL string from formatted string
	NSURL *url = [NSURL URLWithString:urlString];
	
	// Setup and start async download
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
	[request release];	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
	
	TTNetworkRequestStopped();
	[loadingView performSelector:@selector(hide) withObject:nil afterDelay:0.1];
	
	// Error Domain=NSURLErrorDomain Code=-1009 UserInfo=0x373db0 "no Internet connection"
	if ([[error domain] compare:@"NSURLErrorDomain"] == 0 && [error code] == -1009)
	{
		UIAlertView *noInternet = [[[UIAlertView alloc] initWithTitle:@"Internet Connection Unavailable"
															  message:@"Sorry, we were unable to load certain information because an Internet connection could not be found."
															 delegate:self cancelButtonTitle:@"Ok" 
													otherButtonTitles:nil, nil] autorelease];
		[noInternet show];
	}
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
	// Store incoming data into a string 
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	// Create a dictionary from the JSON string
	weatherData = [jsonString JSONValue];
	
	currentTemperature = (int)[[[[weatherData objectAtIndex:0] objectForKey:@"current"] objectForKey:@"fahrenheit"] floatValue];
	NSLog(@"Loaded weather %d", currentTemperature);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedWeatherData" object:nil];

	TTNetworkRequestStopped();
	[loadingView performSelector:@selector(hide) withObject:nil afterDelay:0.1];
}

- (void)dealloc
{
	[weatherData release];
	[responseData release];
    [super dealloc];
}

@end
