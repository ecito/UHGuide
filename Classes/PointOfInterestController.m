//
//  PointOfInterestController.m
//  UHCampusGuide
//
//  Created by Kaleb Fulgham on 11/22/09.
//  Copyright 2009 Honey Bear Webdesign. All rights reserved.
//

#import "PointOfInterestController.h"

#define INTEREST_CACHE_TIME (60*60*24) // 1 day
#define INTEREST_CACHE_TIME_SHORT (60*2) // 2 minutes

@implementation PointOfInterestController
@synthesize pointsOfInterest, urlRequest, interestRequested;

- (id)init
{
	responseData = [[NSMutableData data] retain];
	pointsOfInterest = [[NSMutableArray alloc] init];

	return self;
} 

- (void)getAllPointsOfInterestFromCategory:(InterestCategory *)anInterestCategory
{	
	[self getAllPointsOfInterestFromCategory:anInterestCategory.name
								   withCache:anInterestCategory.caching];
}

- (void)getAllPointsOfInterestFromCategoryWith:(NSString *)name
{
	[self getAllPointsOfInterestFromCategory:name withCache:YES];
	
}

- (void)getAllPointsOfInterestFromCategory:(NSString *)aCategory withCache:(BOOL)cacheStatus
{

// NSLog(@"Getting All Points of Interest From Category %@", aCategory);
	interestRequested = aCategory;
	
	// URL to obtain the points of interest
	NSString *urlAddress = [NSString stringWithFormat:@"http://uhcamp.us.to/interests?category=%@",
								[aCategory stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	// Cancel and Release any old requests
	if (urlRequest)
	{
		[urlRequest cancel];
		[urlRequest release];
		urlRequest = nil;
	}
	
	// Create new URL Request
	urlRequest = [[TTURLRequest alloc] initWithURL:urlAddress delegate:self];
	if (cacheStatus)
	{
		// Using Cache!
		urlRequest.cacheExpirationAge = INTEREST_CACHE_TIME;
	}
	else
	{
		// Use short term cache
		//urlRequest.cacheExpirationAge = INTEREST_CACHE_TIME_SHORT;
		urlRequest.cachePolicy = TTURLRequestCachePolicyNone; // No Cache
	}
    urlRequest.response = self;
    urlRequest.httpMethod = @"GET";
    
    // Dispatch the request.
    [urlRequest send];
}

- (void)requestDidStartLoad:(TTURLRequest*)request
{
	// Setup and start async download
	TTNetworkRequestStarted();
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	if (request.respondedFromCache == YES)
	{
	// NSLog(@"requestDidFinishLoad: Responding from CACHE");
	}
	
	TTNetworkRequestStopped();
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedPointsOfInterest" object:nil];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
// NSLog(@"PointOfInterestController Connection failed: %@", [error description]);
	TTNetworkRequestStopped();
	
	// Error Domain=NSURLErrorDomain Code=-1009 UserInfo=0x373db0 "no Internet connection"
//	if ([[error domain] compare:@"NSURLErrorDomain"] == 0 && [error code] == -1009)
//	{
	UIAlertView *noInternet =
		[[[UIAlertView alloc] initWithTitle:@"Internet Connection Unavailable"
			message:[NSString stringWithFormat:@"Sorry, we were unable to load the %@ point of interest because an Internet connection could not be found.", interestRequested] 
			delegate:self cancelButtonTitle:@"Ok" 
			otherButtonTitles:nil, nil] autorelease];
	[noInternet show];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedPointsOfInterest" object:error];
//	}
}

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response data:(id)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
    // Parse the JSON data that we retrieved from the server.
    NSMutableArray *results = [responseBody JSONValue];
    [responseBody release];
	
	[pointsOfInterest removeAllObjects];
	
	// Loop through each entry in the dictionary...
	for (NSDictionary *interestObject in results)
	{
		NSDictionary *interest = [interestObject objectForKey:@"interest"];
		
	// NSLog(@"Adding interest object: %@", [interest objectForKey:@"name"]);
		Interest *newInterest = [[Interest alloc] initWithName:[interest objectForKey:@"name"]
							   category:[interest objectForKey:@"category_name"]
							description:[interest objectForKey:@"description"]
							 markerIcon:[interest objectForKey:@"marker_icon"]
								picture:[interest objectForKey:@"picture"]
							   latitude:[[interest objectForKey:@"latitude"] floatValue]
							  longitude:[[interest objectForKey:@"longitude"] floatValue]
									URL:[interest objectForKey:@"url"]];
									
		
		[self.pointsOfInterest addObject:newInterest];
		[newInterest release];
	} 
    
    return nil;
}

- (void)dealloc
{
	self.pointsOfInterest = nil;
	[responseData release];
	self.urlRequest.response = nil;
	[urlRequest release];
	self.interestRequested = nil;
	
    [super dealloc];
}


@end
