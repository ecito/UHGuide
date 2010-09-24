#import "LauncherViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation LauncherViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init
{
	if (self = [super init]) 
	{
		self.title = @"UH Guide";
		
		self.navigationItem.backBarButtonItem =
			[[[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered
								   target:nil action:nil] autorelease];
		
		self.navigationItem.leftBarButtonItem =
			[[[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered
											 target:self action:@selector(openCreditsView:)] autorelease];

	}
	return self;
}

- (void)openCreditsView:(id)sender;
{
	NSLog(@"Go to Credits!");
	//[[TTNavigator navigator] openURL:@"uh://credits" animated:YES]; //deprecated
	TTOpenURL(@"uh://credits");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView 
{
  [super loadView];                                       
  _launcherView = [[TTLauncherView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 180)];
  //_launcherView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"UHLauncherBackground.png"]];
  _launcherView.clipsToBounds = NO;
	_launcherView.delegate = self;
  _launcherView.columnCount = 3;

	// Edited three20 TTLauncher kEditHoldTimeInterval = 1000 to disable editing 
	
	NSMutableArray *items = [NSMutableArray arrayWithObjects:
	 [[[TTLauncherItem alloc] initWithTitle:@"Map"
																		image:@"bundle://map2.png"
																			URL:@"uh://campusmap" 
																canDelete:NO] autorelease],
	 [[[TTLauncherItem alloc] initWithTitle:@"Weather"
																		image:@"bundle://weather2.png"
																			URL:@"uh://weather" 
																canDelete:NO] autorelease],
//	 [[[TTLauncherItem alloc] initWithTitle:@"Twitter"
//																		image:@"bundle://twitter2.png"
//																			URL:@"uh://twitter" 
//																canDelete:NO] autorelease],
	 [[[TTLauncherItem alloc] initWithTitle:@"Photos"
																		image:@"bundle://flickr.png"
																			URL:@"uh://photos" 
																canDelete:NO] autorelease],
	 [[[TTLauncherItem alloc] initWithTitle:@"Social Media"
																		image:@"bundle://facebook.png"
																			URL:@"uh://social" 
																canDelete:NO] autorelease],
		 
	 //	
		[[[TTLauncherItem alloc] initWithTitle:@"Directory"
									image:@"bundle://directory.png"
									URL:@"uh://people" canDelete:NO] autorelease],
	 			[[[TTLauncherItem alloc] initWithTitle:@"Shuttles"
	 									  image:@"bundle://uh_shuttle.png"
	 										URL:@"http://www.nextbus.com/wireless/miniRoute.shtml?a=uhouston" canDelete:NO] autorelease],
	 nil];
	
//	if ([self deviceHasCompass]) {
//		[items addObject:[[[TTLauncherItem alloc] initWithTitle:@"UH Live"
//																											image:@"bundle://compass.png"
//																												URL:@"uh://ar" 
//																									canDelete:NO] autorelease]];
//		
//	}
	
	TTLauncherItem *test = [[[TTLauncherItem alloc] initWithTitle:@"Settings"
																										image:@"bundle://settings.png"
																											URL:@"uh://settings" 
																								canDelete:NO] autorelease];
	
	
	
	
	
//	[items addObject:[[[TTLauncherItem alloc] initWithTitle:@"Settings"
//																										image:@"bundle://settings.png"
//																											URL:@"uh://settings" 
//																								canDelete:NO] autorelease]];
	
	
	_launcherView.pages = [NSArray arrayWithObjects:items, nil];
	
	[self.view addSubview:_launcherView];

	// Listen for mini-apps that want to update their badge
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(updateBadgeNumber:) 
//												 name:@"UpdateBadge" object:nil];
												 
	uhPres = [[TTImageView alloc] initWithFrame:CGRectMake(10, _launcherView.frame.size.height + 10, 48, 48)];
	uhPres.defaultImage = [UIImage imageNamed:@"directory.png"];
	uhPres.urlPath = @"http://tweetimag.es/i/uhpres_n.png";
	[self.view addSubview:uhPres];
	
	twitterFeedActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	twitterFeedActivityIndicator.frame = uhPres.bounds;
	[uhPres addSubview:twitterFeedActivityIndicator];
	
	uhPresLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _launcherView.frame.size.height + 56, 56, 50)];
	uhPresLabel.text = @"UHPres says";
	uhPresLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
	uhPresLabel.textColor = [UIColor blackColor];
	uhPresLabel.numberOfLines = 2;
	[self.view addSubview:uhPresLabel];
	
	TwitterFeedView *twitterFeed = [[TwitterFeedView alloc] initWithFrame:CGRectMake(68, _launcherView.frame.size.height + 10, 238, 100)];
	twitterFeed.backgroundColor = [UIColor clearColor];
	twitterFeed.delegate = self;
	twitterFeed.hidden = YES;
	[twitterFeed addStuffToView];
	[twitterFeedActivityIndicator startAnimating];
	[self.view addSubview:twitterFeed];
	
	UIButton *uhWebsite = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 70, self.view.bounds.size.width, 70)];
	uhWebsite.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UHLauncherBackgroundCropped.png"]];
	[uhWebsite addTarget:@"http://uh.edu" action:@selector(openURLFromButton:) forControlEvents:UIControlEventTouchUpInside]; 
	[self.view addSubview:uhWebsite];
	
	[uhPres release];
	[uhPresLabel release];
	[twitterFeed release];
	[uhWebsite release];
	
	// Get current Weather
//	weatherController = [[[WeatherController alloc] init] autorelease];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(updateWeatherBadge:) 
//												 name:@"LoadedWeatherData" object:nil];
//	[weatherController getWeather];								
}

-(void)twitterFeedViewUpdateSuccessful {
	NSLog(@"YAY");
	[twitterFeedActivityIndicator stopAnimating];

}

-(void)twitterFeedViewUpdateFailed {
	NSLog(@"NAY");
	[twitterFeedActivityIndicator stopAnimating];
	uhPresLabel.hidden = YES;
	uhPres.hidden = YES;

}

- (void)updateBadgeNumber:(NSNotification *)notification
{
	NSMutableDictionary *badgeDictionary = [notification object];
	NSLog(@"Updating url[%@] with badge number[%d]", [badgeDictionary objectForKey:@"url"], [[badgeDictionary objectForKey:@"number"] intValue]);
	TTLauncherItem* item = [_launcherView itemWithURL:[badgeDictionary objectForKey:@"url"]];
	item.badgeNumber = [[badgeDictionary objectForKey:@"number"] intValue];
}

//- (void)updateWeatherBadge:(NSNotification *)notification
//{
//	int currentTemp = weatherController.currentTemperature;
//	NSLog(@"Updating weather badge with %d", currentTemp);
//	TTLauncherItem* item = [_launcherView itemWithURL:@"uh://weather"];
//	item.badgeNumber = currentTemp;
//}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLauncherViewDelegate

- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item {
	//[[TTNavigator navigator] openURL:item.URL animated:NO];
	TTOpenURL(item.URL);
}

- (void)launcherViewDidBeginEditing:(TTLauncherView*)launcher {
	[_launcherView endEditing];
//  [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] 
//    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//    target:_launcherView action:@selector(endEditing)] autorelease] animated:YES];
}

- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher {
//  [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (BOOL)deviceHasCompass {
	CLLocationManager *manager = [[CLLocationManager alloc] init];
	BOOL compass = manager.headingAvailable;
	[manager release];
	return compass;
}

- (void)dealloc {
	//[weatherController release];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:@"UpdateBadge"
												  object:nil];
//	[[NSNotificationCenter defaultCenter] removeObserver:self 
//													name:@"LoadedWeatherData"
//												  object:nil];
//	
  [super dealloc];
}

@end
