//
//  CreditsViewController.m
//  UHGuide
//
//  Created by Kaleb Fulgham on 12/14/09.
//  Copyright 2009 University of Houston. All rights reserved.
//

#import "CreditsViewController.h"
#import "NetworkUtility.h"
#import "FlurryAPI.h"

@implementation CreditsViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)init 
{
	if (self = [super init]) 
	{	
		//[[Beacon shared] startSubBeaconWithName:@"credits: opened creditsView" timeSession:YES];
		[FlurryAPI logEvent:@"credits: opened creditsView" timed:YES];

		self.title = @"About Us";
	}
	
	return self;
}

- (IBAction)goToCourseWebsite:(id)sender
{
	NetworkUtility *nUtil = [NetworkUtility sharedInstance]; 
	if ([nUtil startNetwork] == NotReachable) {
		UIAlertView *noInternet = 
		[[[UIAlertView alloc] initWithTitle:@"Internet Connection Unavailable"
									message:@"Sorry, we were unable to load the website because an Internet connection could not be found."
								   delegate:self cancelButtonTitle:@"Ok" 
						  otherButtonTitles:nil, nil] autorelease];
		
		[noInternet show];
	}
	else 
	{
		TTOpenURL(@"http://www.cpl.uh.edu/courses/fall_2009/ubiquitous_computing/");
	}
}

- (IBAction)goToCampusGuideWebsite:(id)sender
{
	NetworkUtility *nUtil = [NetworkUtility sharedInstance]; 
	if ([nUtil startNetwork] == NotReachable) {
		UIAlertView *noInternet = 
		[[[UIAlertView alloc] initWithTitle:@"Internet Connection Unavailable"
									message:@"Sorry, we were unable to load the website because an Internet connection could not be found."
								   delegate:self cancelButtonTitle:@"Ok" 
						  otherButtonTitles:nil, nil] autorelease];
		
		[noInternet show];
	}
	else 
	{
		TTOpenURL(@"http://uhcamp.us.to/");
	}
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	//[[Beacon shared] endSubBeaconWithName:@"credits: opened creditsView"];
	
	[FlurryAPI endTimedEvent:@"credits: opened creditsView" withParameters:nil];

    [super dealloc];
}


@end
