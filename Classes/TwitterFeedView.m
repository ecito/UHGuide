//
//  TwitterFeedView.m
//  CoffeeGroundz
//
//  Created by Andre Navarro on 2/2/10.
//  Copyright 2010 Squirrel Hero All rights reserved.
//

#import "TwitterFeedView.h"
#import "JSON.h"

@implementation TwitterFeedView
@synthesize  urlRequest, delegate;

- (id)init 
{
	if (self = [super init]) 
	{	
		[self setHidden:YES];
		responseData = [[NSMutableData data] retain];
		
	}
	
	return self;
}


-(void)addStuffToView
{
	
	
	self.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4.5]
	
																						/*[TTSpeechBubbleShape shapeWithRadius:5 pointLocation:90
																																			pointAngle:180
																																			 pointSize:CGSizeMake(20,10)]*/
																			 next:
								[TTSolidFillStyle styleWithColor:RGBCOLOR(158, 11, 15) next:
								 [TTSolidBorderStyle styleWithColor:RGBCOLOR(142, 61, 0) width:1 next:nil]]];
	
	NSString *url = @"http://search.twitter.com/search.json?q=from%3AUHPres&rpp=1";
	[self searchTwitter:url];
		
}

-(void)addTwitterText:(NSString*)text
{
	
	// 140 char test
	//text = @"asldjf laksdj laskdjf laskdjf laksjdf lkfjdslakj laksjdfl kj jfkdjoapuoapuwne b fpieubwfpiube abpsudhufh hfudhushauhp asdufn n fuewnaunjfewq";
	
	TTStyledTextLabel* label1 = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
	label1.font = [UIFont systemFontOfSize:14];
	label1.textColor = [UIColor whiteColor];
	label1.text = [TTStyledText textFromXHTML:text lineBreaks:YES URLs:NO];
	label1.contentInset = UIEdgeInsetsMake(4, 8, 4, 4);
	label1.backgroundColor = [UIColor clearColor];
	[label1 sizeToFit];
	[self addSubview:label1];	
	
	
}
	
- (void)searchTwitter:(NSString *)twitterURL
{
			
	// Cancel and Release any old requests
	if (urlRequest)
	{
		[urlRequest cancel];
		[urlRequest release];
		urlRequest = nil;
	}
	
	// Create new URL Request
	urlRequest = [[TTURLRequest alloc] initWithURL:twitterURL delegate:self];
	urlRequest.response = self;
	urlRequest.cachePolicy = TTURLRequestCachePolicyNone;
	urlRequest.cacheExpirationAge = 60*50;
	urlRequest.httpMethod = @"GET";
	
	// Dispatch the request.
	[urlRequest send];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
	NSLog(@" Connection failed: %@", [error description]);
	if (delegate && [delegate respondsToSelector:@selector(twitterFeedViewUpdateFailed)]) {
		[delegate twitterFeedViewUpdateFailed];
	}

//	UIAlertView *noInternet =
//	[[[UIAlertView alloc] initWithTitle:@"Internet Connection Unavailable"
//															message:@"Sorry we weren't able to load CoffeeGround's twitter feed"
//														 delegate:self cancelButtonTitle:@"Ok" 
//										otherButtonTitles:nil, nil] autorelease];
//	[noInternet show];
}

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response data:(id)data
{
	
	NSLog(@"processing response");
	NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	// Parse the JSON data that we retrieved from the server.
	NSMutableDictionary *results = [responseBody JSONValue];
	[responseBody release];

	if (results) {
		NSLog(@"there's results");
		[self addTwitterText:[[[results objectForKey:@"results"] objectAtIndex:0] objectForKey:@"text"]];
		[self transitionFromBottomUp];
		if (delegate && [delegate respondsToSelector:@selector(twitterFeedViewUpdateSuccessful)]) {
			[delegate twitterFeedViewUpdateSuccessful];
		}
	}	
	return nil;
}

- (void)transitionFromBottomUp
{
	[self setHidden:NO];
	
	CABasicAnimation *theAnimation;	
	theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
	theAnimation.duration=.2;
	theAnimation.removedOnCompletion = NO;
	theAnimation.fillMode = kCAFillModeForwards;
	theAnimation.fromValue = [NSNumber numberWithFloat:200.];
//	 [NSNumber numberWithFloat:self.frame.origin.y];
	theAnimation.toValue = [NSNumber numberWithFloat:0.]; //[NSNumber numberWithFloat:self.frame.origin.y - 150];
	[self.layer addAnimation:theAnimation forKey:@"animateLayer"];		
}



- (void)dealloc 
{
	
	
	NSLog(@"DeAlloced Twitter");
	
	[responseData release];
	
	[super dealloc];
}	


@end
