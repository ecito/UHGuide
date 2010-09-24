//
//  SettingsViewController.m
//  UHGuide
//
//  Created by CampusGuide on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "FlurryAPI.h"

@implementation SettingsViewController

- (id)init 
{
	if (self = [super init]) 
	{	
		//[[Beacon shared] startSubBeaconWithName:@"settng: opened settngView" timeSession:NO];
		[FlurryAPI logEvent:@"settng: opened settngView"];

		self.title = @"Settings";
	}
	
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{

	self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"UHLauncherBackground.png"]];

    [super viewDidLoad];
}

-(IBAction)clearCache:(id)sender
{	
	UIAlertView *clearCacheAlert = 
	[[[UIAlertView alloc] initWithTitle:@"Alert" 
								message:@"Are you sure you want to remove all cached data such as Points of Interest?" 
							   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"REMOVE", nil] autorelease];
	[clearCacheAlert show];
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.title == @"Alert")
	{
		if (buttonIndex == 0)
		{
			NSLog(@"Cancelling");
		}
		else
		{
			NSLog(@"Clearing cache");
			//[[Beacon shared] startSubBeaconWithName:@"settng: Cleared Cache" timeSession:NO];
			[FlurryAPI logEvent:@"settng: Cleared Cache"];

			[[TTURLCache sharedCache] removeAll:YES];
		}
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
