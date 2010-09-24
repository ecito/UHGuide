//
//  InterestCategoryController.m
//  UHGuide
//
//  Created by Kaleb Fulgham on 12/10/09.
//  Copyright 2009 University of Houston. All rights reserved.
//

#import "InterestCategoryController.h"

#define INTEREST_CACHE_TIME (60*60*24) // 1 day

@implementation InterestCategoryController
@synthesize categories, urlRequest;

- (id)init
{
	responseData = [[NSMutableData data] retain];
	categories = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)getAllCategories
{	
	//NSLog(@"Getting all Categories");

	// Create NSURL string for categories
	NSString *urlAddress = @"http://uhcamp.us.to/categories.json";
	
	// Cancel and Release any old requests
	if (urlRequest)
	{
		[urlRequest cancel];
		[urlRequest release];
		urlRequest = nil;
	}
	
	// Create new URL Request
	urlRequest = [[TTURLRequest alloc] initWithURL:urlAddress delegate:self];
	urlRequest.cachePolicy = TTURLRequestCachePolicyDefault;
	urlRequest.cacheExpirationAge = INTEREST_CACHE_TIME;
    urlRequest.response = self;
    urlRequest.httpMethod = @"GET";
    
    // Dispatch the request.
    [urlRequest send];
}

- (void)requestDidStartLoad:(TTURLRequest*)request
{
	// Setup and start async download
	TTNetworkRequestStarted();
	[categories removeAllObjects];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	if (request.respondedFromCache == YES)
	{
		//NSLog(@"requestDidFinishLoad: Responding from cache %d", request.cacheExpirationAge);
	}
	
	TTNetworkRequestStopped();
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedInterestCategories" object:nil];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
// NSLog(@"Connection failed: %@", [error description]);
	TTNetworkRequestStopped();
	
	// Error Domain=NSURLErrorDomain Code=-1009 UserInfo=0x373db0 "no Internet connection"
	//if ([[error domain] compare:@"NSURLErrorDomain"] == 0 && [error code] == -1009)
	//{
	UIAlertView *noInternet = [[[UIAlertView alloc] initWithTitle:@"Internet Connection Unavailable"
				  message:@"Sorry, we were unable to load the Point of Interest selector because an Internet connection could not be found."
				 delegate:self cancelButtonTitle:@"Ok" 
		otherButtonTitles:nil, nil] autorelease];
	[noInternet show];
	//}
}

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response data:(id)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
    // Parse the JSON data that we retrieved from the server.
    NSMutableArray *categoriesArray = [responseBody JSONValue];
// NSLog(@"Categories JSON:\n%@", responseBody);
    [responseBody release];

	// Loop through each entry in the dictionary...
	for (NSDictionary *categoryDictionary in categoriesArray)
	{
		NSDictionary *categoryData = [categoryDictionary objectForKey:@"category"];
	// NSLog(@"Adding interest object: %@", [categoryData objectForKey:@"name"]);
		
		NSString *source = [categoryData objectForKey:@"source"];
		BOOL shouldCache;
		if ([source isEqualToString:@"static"])
		{
		// NSLog(@"Should use CACHE");
			shouldCache = YES; // static 
		}
		else
		{
		// NSLog(@"Should NOT use CACHE");
			shouldCache = NO; // dynamic
		}
		
		[self.categories addObject:
		 [[InterestCategory alloc] initWithName:[categoryData objectForKey:@"name"]
									 categoryId:[[categoryData objectForKey:@"id"] intValue]
								  defaultMarker:[categoryData objectForKey:@"default_marker"]
									description:[categoryData objectForKey:@"description"]
									caching:shouldCache
		  ]];
		  
	} 
    
    return nil;
}

- (void)dealloc
{
	self.categories = nil;
	[responseData release];
	urlRequest.response = nil;
	[urlRequest cancel];
	[urlRequest release];
	urlRequest = nil;
    [super dealloc];
}

@end
