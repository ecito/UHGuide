//
//  ProgrammaticMapViewController.m
//  ProgrammaticMap
//
//  Created by Campus Guide on 9/25/09.
//  Copyright University of Houston 2009. All rights reserved.
//

#import "MapViewController.h"
#import "FlurryAPI.h"
#import "RMMarkerManager.h"
#import "RMMarker.h"
#import "RMDBMapSource.h"
#import "RMLayerSet.h"
#import "Sqlite.h"
#import "MarkerLabelView.h"
#import "NetworkUtility.h"
#import "FlurryAPI.h"

@implementation MapViewController

@synthesize mapView, routePath, pointOfInterestController, interestCategoryController, northWestCoverage, southEastCoverage, previousMapCenter, centerOfCoverage, centerOfMap, resultsTableView, filteredBuildings, markerManager;
@synthesize locationManager, myLocationCoordinates, segmentedSearchDirections, myLocationBuilding;
@synthesize  searchBar, startBar, destinationBar, buildingStart, buildingEnd, interestTabBar, statusBarView;

#pragma mark -
#pragma mark Load view and data

/** This populates the buildings array from a sqlite3 database generated from the server */
- (void)loadBuildingsFromDatabase
{
	//NSLog(@"Loading database, buildings");
	Sqlite *sqlite = [[Sqlite alloc] init];
	
    NSString *file = [[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"sqlite3"];
	if (![sqlite open:file])
	{
		//NSLog(@"Error: Failed to load database, buildings.");
		return;
		
	}
	
	// Execute Query
	NSArray *results = [sqlite executeQuery:@"SELECT * FROM buildings ORDER BY name;"];

	// Create and Store Building Objects
	for (NSDictionary *item in results)
	{
		Building *building = [[Building alloc] initWithName:[item objectForKey:@"name"] 
								  code:[item objectForKey:@"code"]
								number:[[item objectForKey:@"number"] intValue]
							  latitude:[[item objectForKey:@"latitude"] floatValue]
							 longitude:[[item objectForKey:@"longitude"] floatValue]];
		
		[buildings addObject:building];
		[building release];
	}
	
	
	[results release];
	[sqlite release];
}

/** Someone is calling this and crashing the app */
- (void)keyboardWillShow:(NSNotification *)notification {
	;	
}

/** Here we set up the whole view */
- (void)viewDidLoad {
	//NSLog(@"viewDidLoad");
    [super viewDidLoad];
	//[[Beacon shared] startSubBeaconWithName:@"mapView: Opened mapView" timeSession:YES];
	[FlurryAPI logEvent:@"mapView: Opened mapView" timed:YES];

	filteredBuildings = [[NSMutableArray alloc] init];
	pointOfInterestController = [[PointOfInterestController alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadedPointsOfInterest:) 
												 name:@"LoadedPointsOfInterest" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadedInterestCategories:) 
												 name:@"LoadedInterestCategories" object:nil];
	
	UIColor *tintColor = RGBCOLOR(204, 0, 0);

	// Add Search Bar
	searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
	searchBar.tintColor = tintColor;
	searchBar.placeholder = @"Search buildings...";
	[searchBar sizeToFit];
	[searchBar retain];
	self.navigationItem.titleView = searchBar;
	//self.navigationItem.titleView.frame = CGRectMake(0, 0, 300,45);	

	[searchBar sizeToFit]; // Get the default height for a search bar.
	buildings = [[NSMutableArray alloc] init];
	
	// Initialize LocationManager
	if (!locationManager)
	{
		locationManager = [[CLLocationManager alloc] init];
		CLLocation *location = [locationManager location];
		//[[Beacon shared] setBeaconLocation:location];
		[FlurryAPI setLocation:location];
	}
	
	// Setup CoreLocation
	[[self locationManager] startUpdatingLocation];
	//[[self locationManager] startUpdatingHeading]; // OOPS: Left this in v1.0 

	
	// Load Buildings
	[self loadBuildingsFromDatabase];
	
	// Results Table
	resultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,200)]; // CGRect reset in switchBetweenSearchAndDirectionsMode
	resultsTableView.delegate = self;
	resultsTableView.dataSource = self;
	[self.view addSubview:resultsTableView];
	[resultsTableView setHidden:YES];
	//searchBar.showsCancelButton = YES;

	// Add status bar
	statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,25)];
	statusBarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha: 0.0];
	[statusBarView setHidden:YES];
	[[self view] addSubview:statusBarView];
	
	// Category / Interest Bar
	interestCategoryController = [[InterestCategoryController alloc] init];
	[self setStatusBarWith:@"Loading Categories..." andLoading:YES];
	[interestCategoryController getAllCategories];
	
	// Toolbar
	toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleDefault;
	toolbar.tintColor = tintColor;
	[toolbar sizeToFit];
	toolbar.frame = CGRectMake(0, 374, 320, 42);
	
	// Search / Directions - Segmented Control
	segmentedSearchDirections = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Search", @"Directions", nil]] autorelease];
	[segmentedSearchDirections addTarget:self action:@selector(searchDirections:) forControlEvents:UIControlEventValueChanged];
	segmentedSearchDirections.selectedSegmentIndex = 0;
	segmentedSearchDirections.frame = CGRectMake(0, 0, 250, 25);
	segmentedSearchDirections.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedSearchDirections.tintColor = tintColor;

	[[self view] addSubview:toolbar];
	
	//Create a button
	UIBarButtonItem *locateButton = [[UIBarButtonItem alloc]
	initWithImage:[UIImage imageNamed:@"locateButton.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(locateMeOnMap:)];
	
	UIBarButtonItem *searchDirectionsButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedSearchDirections];
	//initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(findMyLocation:)];

	[toolbar setItems:[NSArray arrayWithObjects:locateButton,searchDirectionsButton,nil]];
	
	// Create starting GEO Points
	// WOEID: 12791325
	centerOfMap.latitude = 29.72072515;
	centerOfMap.longitude = -95.34287452;
	previousMapCenter = centerOfMap; // Save the current mapCenter
	
	// Create the Map View
	self.mapView = [[[RMMapView alloc] initWithFrame:CGRectMake(0,0,320,375) WithLocation:centerOfMap] autorelease];
	
	// Set the Tile Source
	RMDBMapSource *dbTileSource = [[[RMDBMapSource alloc] initWithPath:@"map_tiles.sqlite3"] autorelease];
	centerOfCoverage = [dbTileSource centerOfCoverage];
	self.mapView.contents.tileSource = dbTileSource;
	self.mapView.delegate = self;
	self.mapView.deceleration = YES;
	
	// Set Zoom Levels
	[[mapView contents] setMinZoom:14];	
	[[mapView contents] setZoom:15.0]; // Original zoom level
	[[mapView contents] setMaxZoom:18];
	
	// Set Map Corners
	//NSLog(@"lat: %f lon: %f", self.northWestCoverage.latitude, self.northWestCoverage.longitude);
	//NSLog(@"lat: %f lon: %f", self.southEastCoverage.latitude, self.southEastCoverage.longitude);
	
	CLLocationCoordinate2D northWestOffsetted;
	CLLocationCoordinate2D southEastOffsetted;
	northWestOffsetted.latitude = [dbTileSource topLeftOfCoverage].latitude + 0.01;
	northWestOffsetted.longitude = [dbTileSource topLeftOfCoverage].longitude - 0.01;
	southEastOffsetted.latitude = [dbTileSource bottomRightOfCoverage].latitude - 0.01;
	southEastOffsetted.longitude = [dbTileSource bottomRightOfCoverage].longitude + 0.01;
	
	self.northWestCoverage = northWestOffsetted;
	self.southEastCoverage = southEastOffsetted;
		
	
	[mapView setBackgroundColor:[UIColor whiteColor]];
	markerManager = [mapView markerManager];
	
	[[self view] addSubview:mapView];
	[[self view] sendSubviewToBack:mapView];
	
	
	// Directions Bars
	startBar = [[UISearchBar alloc] init];
	startBar.delegate = self;
	startBar.tintColor = tintColor;
	[[self view] addSubview:startBar];
	[startBar sizeToFit];
	[startBar setHidden:YES];

	destinationBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, 0, 40)];
	destinationBar.delegate = self;
	destinationBar.tintColor = tintColor;
	[[self view] addSubview:destinationBar];
	[destinationBar sizeToFit];
	[destinationBar setHidden:YES];
	
	// Add a My Location fake Building
	myLocationBuilding = [[Building alloc] initWithName:@"My Current Location" code:@"" number:-2 
												   latitude:centerOfMap.latitude 
												  longitude:centerOfMap.longitude];
	
	// Clean up
	[tintColor release];	
}

/** This gets called after server response completion */
- (void)loadedPointsOfInterest:(NSNotification *)notification
{
	id notificationErrorObj = [notification object];
	if (!notificationErrorObj)
	{
		if (segmentedSearchDirections.selectedSegmentIndex == 0)
		{
			[self removeAllInterestMarkers];
			// Let's just remove all the markers...
			[self removeAllBuildingMarkers];
			//NSLog(@"Adding %d markers for Interests", self.pointOfInterestController.pointsOfInterest.count);
			
			for (Interest *interest in self.pointOfInterestController.pointsOfInterest)
			{
				RMMarker *newMarker = [self addMarkerForInterest:interest];
				[newMarker release];
			}
			
			// Zoom out of Map and center
			[[mapView contents] setZoom:mapView.contents.minZoom];
			[[mapView contents] setMapCenter:centerOfMap];
			
			[statusBarView setHidden:YES];
		}
		else 
		{
			Interest *shuttleStart = [self findNearestInterestToBuilding:buildingStart];
			Interest *shuttleEnd = [self findNearestInterestToBuilding:buildingEnd];
			
			[self addMarkerForInterest:shuttleStart];
			[self addMarkerForInterest:shuttleEnd];
			
			// lets find the route!		
		}
	}
	else
	{
		// There was an error
		// TODO: Possibly, handle the error.
		[statusBarView setHidden:YES];
	}
}

/** This gets called after server response completion */
- (void)loadedInterestCategories:(NSNotification *)notification
{
	[statusBarView setHidden:YES];

	//NSObject *obj = [notification object];
	NSInteger numberOfCategories = self.interestCategoryController.categories.count;
	//NSLog(@"Loading %d Interest categories", numberOfCategories);
	
	CGRect navigationFrame = TTNavigationFrame();
	interestTabBar = [[TTTabStrip alloc] initWithFrame:CGRectMake(0, navigationFrame.size.height-80, navigationFrame.size.width, 40)];
	interestTabBar.delegate = self;

	NSMutableArray *tabItems = [[NSMutableArray alloc] init];
	for (InterestCategory *category in self.interestCategoryController.categories)
	{
		TTTabItem *tabItem = [[[TTTabItem alloc] initWithTitle:category.name] autorelease];
		tabItem.object = category;
		[tabItems addObject:tabItem];
	}
	TTTabItem *tabItem = [[[TTTabItem alloc] initWithTitle:@""] autorelease];
	InterestCategory *fakeInterestCategory = [[InterestCategory alloc] initWithName:@"" 
													categoryId:-1
													defaultMarker:@"" 
													description:@""
													caching:NO];
	tabItem.object = fakeInterestCategory;
	[tabItems addObject:tabItem];
	interestTabBar.tabItems = [NSArray arrayWithArray:tabItems];
	
	interestTabBar.selectedTabIndex = numberOfCategories;
	[self.view addSubview:interestTabBar];
	[fakeInterestCategory release];
	[tabItems release];
}

#pragma mark -
#pragma mark Search and directions

- (void)searchDirections:(id)sender
{
	UISegmentedControl *segmentControl = sender;
	NSInteger index = segmentControl.selectedSegmentIndex;
	
	[self switchBetweenSearchAndDirectionsMode:index];
}

- (void)switchBetweenSearchAndDirectionsMode:(NSInteger)switchTo
{
	// Search Mode
	if (switchTo == 0)
	{

		self.navigationItem.title = nil;
		self.navigationItem.titleView = searchBar;
		self.navigationItem.rightBarButtonItem = nil;
		resultsTableView.frame = CGRectMake(0,0,320,200);
		
		searchBar.text = @"";
		[statusBarView setHidden:YES];
		[startBar setHidden:YES];
		[destinationBar setHidden:YES];
		[interestTabBar setHidden:NO];
		[markerManager removeMarkers];
		routePath = nil;
		
		//[buildingStart release];
		buildingStart = nil;
		//[buildingEnd release];
		buildingEnd = nil;
	}
	else
	{

		// Show beginning of directions
		[self removeAllInterestMarkers];
		[interestTabBar setHidden:YES];
		[interestTabBar setSelectedTabIndex:self.interestCategoryController.categories.count];
		self.navigationItem.title = @"Directions";
		self.navigationItem.titleView = nil;
		resultsTableView.frame = CGRectMake(0,40,320,160);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																	target:self
																	action:@selector(cancelDirectionsMode:)];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
		
		//[buildingStart release];
		buildingStart = nil;
		//[buildingEnd release];
		buildingEnd = nil;
		
		startBar.text = @"";
		destinationBar.text = @"";
		
		// Show Start Search Bar
		[startBar setHidden:NO];
	}
}

- (void)cancelDirectionsMode:(id)sender
{
	[startBar endEditing:YES];
	[destinationBar endEditing:YES];
	
	[startBar setHidden:YES];
	[destinationBar setHidden:YES];
	
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																		target:self
																		action:@selector(editDirections:)];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	//[self switchBetweenSearchAndDirectionsMode:0];
	//segmentedSearchDirections.selectedSegmentIndex = 0;
}

- (void)editDirections:(id)sender
{
	[startBar setHidden:NO];
	[destinationBar setHidden:NO];
	
	resultsTableView.frame = CGRectMake(0,88,320,112);
	
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																target:self
																action:@selector(cancelDirectionsMode:)];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filteredBuildings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if (filteredBuildings.count > 0)
	{
		Building *building = [filteredBuildings objectAtIndex:indexPath.row];
				
		cell.textLabel.text = building.name;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
		if ([building.name isEqualToString:@"My Current Location"])	
		{
			cell.textLabel.textColor = [UIColor blueColor];
		}

    }
    return cell;
}

- (void)didSelectBuilding:(Building *)building 
{
	//Directions
	// Check if already selected one building
	if (!buildingStart)
	{
		startBar.text = building.name;
		buildingStart = building;
		//NSLog(@"Selected Starting Building: %@", buildingStart.name);
		
		[destinationBar setHidden:NO];
		[resultsTableView setHidden:YES];
		resultsTableView.frame = CGRectMake(0,88,320,112);
	}
	else
	{
		destinationBar.text = building.name; // Must remain here!
		buildingEnd = building;	
		[self calculateDirections];
	}
}

- (void)calculateDirections
{
	if (buildingStart && buildingEnd)
	{
		// Only show both building markers on map
		[markerManager removeMarkers];
		
		
		//NSLog(@"Building start: %@", buildingStart.name);
		//NSLog(@"Building end: %@", buildingEnd.name);
		
		// Draw line in between
		routePath = [[RMPath alloc] initForMap:self.mapView];
		[routePath setLineColor:[UIColor redColor]];	
		
		RMLatLong routePointStart,routePointEnd;
		if(buildingStart.longitude < buildingEnd.longitude)
		{
			routePointStart.latitude = buildingEnd.latitude;
			routePointStart.longitude = buildingEnd.longitude;
			routePointEnd.latitude = buildingStart.latitude;
			routePointEnd.longitude = buildingStart.longitude;
		}
		else
		{
			routePointStart.latitude = buildingStart.latitude;
			routePointStart.longitude = buildingStart.longitude;
			routePointEnd.latitude  = buildingEnd.latitude;
			routePointEnd.longitude = buildingEnd.longitude;
		}
		[routePath addLineToLatLong:routePointStart];
		[routePath addLineToLatLong:routePointEnd];
		[[[self.mapView contents] overlay] addSublayer:routePath];
		
		// Add Marker
		NSString *buildingStartMarkerIcon = @"building_green.png";
		NSString *buildingEndMarkerIcon = @"building_red.png";
		if (buildingEnd.number == -2) // Check if My Location
		{
			buildingEndMarkerIcon = @"marker_location.png";
		}
		
		if (buildingStart.number == -2) // Check if My Location
		{
			buildingStartMarkerIcon = @"marker_location.png";
		}
		[self addMarkerForBuilding:buildingEnd withMarkerIcon:buildingEndMarkerIcon];
		[self addMarkerForBuilding:buildingStart withMarkerIcon:buildingStartMarkerIcon];
		

		// Take directions items off of the map screen
		[startBar endEditing:YES];
		[destinationBar endEditing:YES];
		
		[startBar setHidden:YES];
		[destinationBar setHidden:YES];
		
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																					 target:self
																					 action:@selector(editDirections:)];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
		
		// Update Status bar with Distance and Approx. Travel Time
		float distanceBetween = [self sphericalDistanceFromLat1:routePointStart.latitude 
														   Lon1:routePointStart.longitude
														 toLat2:routePointEnd.latitude
														   Lon2:routePointEnd.longitude];
		// 3mph -> 4.828kph -> 80.46mpm	
		// 2.5mph -> 67.05mpm	
		// 2mph -> 53.64mpm	
		float estWalkTime = distanceBetween/(67.05 - 10); 	// -10 for non-straight path correction																	
		[self setStatusBarWith:[NSString stringWithFormat:@"Distance: %.1f meters / Walk Time: %.1f minutes", distanceBetween, estWalkTime] andLoading:NO];
		
		//move map
		CLLocationCoordinate2D midPointLocation;
		midPointLocation.latitude = (buildingStart.latitude + buildingEnd.latitude) / 2.0f;
		midPointLocation.longitude = (buildingStart.longitude + buildingEnd.longitude) / 2.0f;
		[self.mapView moveToLatLong:midPointLocation];
		if (distanceBetween < 200)
			[[mapView contents] setZoom:17.0]; 
		else if (distanceBetween < 500) 
			[[mapView contents] setZoom:16.0];
		else if (distanceBetween < 1000)
			[[mapView contents] setZoom:15.0];
		else 
			[[mapView contents] setZoom:14.0];
		
		
		// Redraw line to ensure proper location
		[routePath setLineWidth:10.0];
		[routePath release];
		
		
		//get nearest shuttle stops
		InterestCategory *interestCategory = [[InterestCategory alloc] initWithName:@"Shuttles" categoryId:4 defaultMarker:@"" description:@"" caching:YES];
		[self.pointOfInterestController getAllPointsOfInterestFromCategory:interestCategory];
		[interestCategory release];
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Building *building = [filteredBuildings objectAtIndex:indexPath.row];

	if(building.number != -1)
	{
		if (segmentedSearchDirections.selectedSegmentIndex == 0)
		{
			// Search
			// Remove all other buildings
			[self removeAllBuildingMarkers];
			[self addMarkerForBuilding:building];
			//move map
			CLLocationCoordinate2D buildingLocation;
			buildingLocation.latitude = building.latitude;
			buildingLocation.longitude = building.longitude;
			[self.mapView moveToLatLong:buildingLocation];
				
			[searchBar endEditing:YES];
			searchBar.text = building.name;
		}
		else
		{
			[self didSelectBuilding:building];
		}
	}
}

/** sets the top status bar with the specified text and a loading indicator if loading is true */
- (void)setStatusBarWith:(NSString *)text andLoading:(BOOL)loading
{
	if (loading)
	{
		TTActivityLabel* label = [[[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleBlackBanner] autorelease];
		label.text = text;
		[label sizeToFit];
		label.frame = CGRectMake(0,0,320,25);
		[statusBarView removeAllSubviews];
		[statusBarView addSubview:label];
		
	}
	else 
	{

		UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,25)];
		distance.text = text;
		distance.textColor = [UIColor whiteColor];
		distance.textAlignment = UITextAlignmentCenter;
		distance.font = [UIFont systemFontOfSize:12];
		distance.backgroundColor = [UIColor colorWithWhite:0.0 alpha: 0.8];
		[statusBarView removeAllSubviews];
		[statusBarView addSubview:distance];
		[distance release];
	}

	[statusBarView setHidden:NO];
	

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
	if (aSearchBar == startBar || aSearchBar == destinationBar)
	{
		if (buildingStart && buildingEnd)
		{
			[self calculateDirections];
		}
	}
}

/** This gets called after each character input */
- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText
{
    // Directions
	// Check if startBar is being editted
	if (aSearchBar == startBar)
	{
		//NSLog(@"nil the buildingStart");
		buildingStart = nil;
	}
	else {
		//NSLog(@"Do not nil the buildingStart");
	}

    
    // Clean out the filter
    [filteredBuildings removeAllObjects];
	
    NSString *query = aSearchBar.text;
	
	if (query.length == 0)
	{
		
		[resultsTableView setHidden:YES];

		// Only search if we have a non-zero length query string
		//filteredBuildings = [buildings mutableCopy];
		//[filteredBuildings addObjectsFromArray:buildings];
		//	NSLog(@"array:%@", filteredNames);
		
	}
	else
	{
		if (aSearchBar != searchBar && [self findMyLocation])
		{
			//NSLog(@"aSearchBar != searchBar, buildingStart Number: %d", buildingStart.number);
			
			if (buildingStart == nil || (buildingStart != nil && buildingStart.number != -2))
			{
				[filteredBuildings addObject:myLocationBuilding];
			}
		}
	
		[resultsTableView setHidden:NO];
		
		for (Building *building in buildings)
		{
			// Start by assuming that the name matches.
			NSRange range = [building.name rangeOfString:query options:NSCaseInsensitiveSearch];
			if (range.length > 0)
			{
				[filteredBuildings addObject:building];
				//NSLog(@"Name: %@, Name inside filter: -, Count: %d", building.name, filteredBuildings.count);
			}
		}
	}
    
    // Add a placeholder if we ended up with no results
    if (filteredBuildings.count == 0)
	{
		[filteredBuildings removeAllObjects];
		[filteredBuildings addObject:myLocationBuilding];
    }
    
	//NSLog(@"searchBar:textDidChange: ending");
    [resultsTableView reloadData];
}

- (void)keyboardWillHide:(NSNotification *)notification
{

	[resultsTableView setHidden:YES];
    // This assumes that no one else cares about the table view's insets...
//    [self.tableView setContentInset:UIEdgeInsetsZero];
//    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}


- (void)didReceiveMemoryWarning {
	//[[Beacon shared] startSubBeaconWithName:@"mapView: MemoryWarning" timeSession:NO];
	[FlurryAPI logEvent:@"mapView: MemoryWarning"];

    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	
    // Release anything that's not essential, such as cached data
	[markerManager removeMarkers];
	[[TTURLCache sharedCache] removeAll:YES];
	[mapView didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark mapView delegates

/** Hide the keyboard when we touch the map */
- (void) afterMapTouch: (RMMapView*) map
{
	[searchBar resignFirstResponder];
}

/** Prevent the user from scrolling out of the campus map  */
- (void) afterMapMove:(RMMapView *)map
{
	//NSLog(@"Checking after move...");
	RMLatLongBounds bounds = [map.contents getScreenCoordinateBounds];

	// Check if out of bounds?
	if ( (bounds.northWest.latitude > northWestCoverage.latitude || bounds.southEast.latitude < southEastCoverage.latitude)
		|| bounds.northWest.longitude < northWestCoverage.longitude || bounds.southEast.longitude > southEastCoverage.longitude)
	{	
		//NSLog(@"Trying to go outside of bounds!");
		//self.mapView.contents.mapCenter = ;
		CGPoint centerOfMapPoint = [map.contents latLongToPixel:map.contents.mapCenter];
		CGPoint previousCenterOfMap = [map.contents latLongToPixel:previousMapCenter];
		//NSLog(@"centerOfMap(%f,%f) and previousCenterOfMap(%f,%f)",centerOfMapPoint.x,centerOfMapPoint.y, previousCenterOfMap.x,previousCenterOfMap.y);
		
		CGSize delta; 
		delta.width = centerOfMapPoint.x-previousCenterOfMap.x; 
		delta.height = centerOfMapPoint.y-previousCenterOfMap.y; 
		[map.contents moveBy:delta];
		//[map.contents moveToLatLong:previousMapCenter];
	}
	
	// Save the current mapCenter
	previousMapCenter = map.contents.mapCenter;
	
	// Reset lineWidth to redraw line
	if(routePath)
	{
		[routePath setLineWidth:10.0];
	}
}

#pragma mark -
#pragma mark Marker Manipulation

/** Returns a UIView that looks like mapkit's label with the specified title and subtitle */
- (UIView *)makeMarkerLabelWithTitle:(NSString *)title andSubTitle:(NSString *)subTitle
{
	CGRect bounds; //= CGRectMake(0, 0, 0, 0);
	bounds.size = ([title sizeWithFont:[UIFont systemFontOfSize:14]].width > [subTitle sizeWithFont:[UIFont systemFontOfSize:12]].width ? [title sizeWithFont:[UIFont systemFontOfSize:14]] : [subTitle sizeWithFont:[UIFont systemFontOfSize:12]]);
	if (bounds.size.width > 260) // this is for very long title lengths
	{
		bounds.size.width = 260;
	}
	
	UILabel *markerLabelTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, bounds.size.width, bounds.size.height)];
	markerLabelTitle.backgroundColor = [UIColor clearColor];
	markerLabelTitle.text = title;
	markerLabelTitle.textColor = [UIColor whiteColor];
	markerLabelTitle.font = [UIFont systemFontOfSize:14];
	
	UILabel *markerLabelSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 22, markerLabelTitle.frame.size.width, bounds.size.height)];
	markerLabelSubTitle.backgroundColor = [UIColor clearColor];
	markerLabelSubTitle.text = subTitle;
	markerLabelSubTitle.textColor = [UIColor whiteColor];
	markerLabelSubTitle.font = [UIFont systemFontOfSize:12];
	
	
	UIView *markerLabel = [[UIView alloc] initWithFrame:CGRectMake(-70, -56, markerLabelTitle.frame.size.width, 56)]; // set size based on text length
	markerLabel.backgroundColor = [UIColor clearColor];	
	
	UIImageView *markerLabelLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 99, 56)];
	[markerLabelLeft setImage:[UIImage imageNamed:@"markerLabelLeft.png"]];
	
	int removeExtraSpace = markerLabelTitle.frame.size.width; // this is for very short text lenghts 
	if (removeExtraSpace > 90)
		removeExtraSpace = 90;


	UIImageView *markerLabelMiddle = [[UIImageView alloc] initWithFrame:CGRectMake(markerLabelLeft.bounds.size.width, 0, markerLabelTitle.frame.size.width - removeExtraSpace, 56)];
	[markerLabelMiddle setImage:[UIImage imageNamed:@"markerLabelMiddle.png"]];
	
	UIImageView *markerLabelRight = [[UIImageView alloc] initWithFrame:CGRectMake(markerLabelLeft.bounds.size.width + markerLabelMiddle.bounds.size.width, 0, 38, 56)];
	[markerLabelRight setImage:[UIImage imageNamed:@"markerLabelRight.png"]];
	
	[markerLabel addSubview:markerLabelLeft];
	[markerLabel addSubview:markerLabelMiddle];
	[markerLabel addSubview:markerLabelRight];
	[markerLabel addSubview:markerLabelTitle];
	[markerLabel addSubview:markerLabelSubTitle];

	[markerLabelLeft release];
	[markerLabelMiddle release];
	[markerLabelRight release];
	[markerLabelTitle release];
	
	return markerLabel;
	
}

/** forward over to addMarkerForBuilding withMarkerIcon */
- (void)addMarkerForBuilding:(id)aBuilding
{
	[self addMarkerForBuilding:aBuilding withMarkerIcon:@"building.png"];
}

/** Adds a marker for a building and creates a label for it */
- (void)addMarkerForBuilding:(id)aBuilding withMarkerIcon:(NSString *)anIcon
{
	//[markerManager removeMarkers];

	//NSLog(@"Creating marker building object");
	
	Building *building = aBuilding;
	
	
	RMMarker *marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:anIcon]];
	marker.data = building;

	// add this marker to the map using the marker manager
	CLLocationCoordinate2D buildingLocation;
	buildingLocation.latitude = building.latitude;
	buildingLocation.longitude = building.longitude;
	
	NSString *subtitle = @"";
	if (building.number >= 0)
	{ 
		subtitle = [NSString stringWithFormat:@"%d - (%@)", building.number, building.code];
	}
	else
	{
		Building *nearestBuilding = [self findNearestBuilding:buildingLocation];
		if(nearestBuilding)
		{
			subtitle = [NSString stringWithFormat:@"Near %@", nearestBuilding.name];
		}
	}
	[marker setLabel:[self makeMarkerLabelWithTitle:building.name andSubTitle:subtitle]];


	[marker replaceImage:[[UIImage imageNamed:anIcon] CGImage] anchorPoint:CGPointMake(0.4,1.0)];

	[markerManager addMarker:marker AtLatLong:buildingLocation];
	
//	[self.mapView moveToLatLong:buildingLocation];
//	[self.mapView moveBy:CGSizeMake(-marker.labelView.size.width/4, 0)];
	// Add marker to the map
	//can be released and accessed through the marker manager later
	[marker release];
	
}

/** Adds a marker for an interest */
- (RMMarker*)addMarkerForInterest:(id)aInterest
{
	
	
	Interest *interest = aInterest;
	//NSLog(@"Adding Interest Point of name: %@",interest.name);
	
	RMMarker *marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:interest.markerIcon]];
	marker.data = interest;

//	[marker replaceImage:[[UIImage imageNamed:interest.markerIcon] CGImage] anchorPoint:CGPointMake(0.4,1.0)];
	// add this marker to the map using the marker manager
	CLLocationCoordinate2D InterestLocation;
	InterestLocation.latitude = interest.latitude;
	InterestLocation.longitude = interest.longitude;
	// add this label to the marker
	
	[markerManager addMarker:marker AtLatLong:InterestLocation];
	
	//can be released and accessed through the marker manager later

	return marker;
}


- (void)removeAllLabels
{
	NSArray *markers = [markerManager getMarkers];
	NSInteger markerCount = markers.count;
	
	for (NSInteger i=0; i<markerCount; i++)
	{
	    RMMarker *marker = [markers objectAtIndex:i];
		
		if (![marker isKindOfClass:[RMPath class]])
		{
			// Remove labels from everything but Building
			id markerClass = marker.data;
			if (![markerClass isKindOfClass: [Building class]] && ![markerClass isKindOfClass: [RMPath class]])
			{
				[marker removeLabel];
			}
		}
	}
}

- (void)removeAllBuildingMarkers
{
	NSArray *markers = [markerManager getMarkers];
	NSInteger markerCount = markers.count;

	for (NSInteger i=0; i<markerCount; i++)
	{
	    RMMarker *marker = [markers objectAtIndex:i];

		id markerClass = marker.data;
		if ([markerClass isKindOfClass: [Building class]])
		{
			[markerManager removeMarker:marker];
			marker = nil;
			[marker release];
		}
	}
}

- (void)removeAllInterestMarkers
{
	NSArray *markers = [markerManager getMarkers];
	NSInteger markerCount = markers.count;
	
	NSMutableArray *markersToKeep = [[NSMutableArray alloc] initWithArray:markers];
	
	for (NSInteger i=0; i<markerCount; i++)
	{
	    //NSLog(@"In Interest loop");
		RMMarker *marker = [markersToKeep objectAtIndex:i];
		
		id markerClass = marker.data;
		if ([markerClass isKindOfClass: [Interest class]])
		{
			Interest *interest = markerClass;
			NSLog(@"Removing marker, %@", interest.name);
			[markerManager removeMarker:marker];
			marker = nil;
			[marker release];
		}
		else 
		{
			//NSLog(@"Other class!");
		}
	}
	
	[markersToKeep release];
}
/** Removes all markers that do not have an associated class (e.g. Buildings)  */
- (void)removeAllClasslessMarkers
{
	NSArray *markers = [markerManager getMarkers];
	NSInteger markerCount = markers.count;
	
	//NSLog(@"Starting to remove all Classless Makers");
	
	for (NSInteger i=0; i<markerCount; i++)
	{
	    id markerClass = [markers objectAtIndex:i];

		if (![markerClass isKindOfClass: [RMPath class]])
		{
			//NSLog(@"Not RMPath Maker");
			RMMarker *marker = markerClass;
			if (marker.data == nil)
			{
				[markerManager removeMarker:marker];
				marker = nil;
				[marker release];
			}
		}
		else {
						//NSLog(@"YES RMPath Maker");
		}

	}
	//NSLog(@"Finished removing all Classless Makers");
}

/** Gets called when an interest is clicked */
- (void)tabBar:(TTTabBar*)tabBar tabSelected:(NSInteger)selectedIndex
{
	if (selectedIndex != self.interestCategoryController.categories.count) 
	{

		//NSLog(@"TabBar selectedIndex: %d withTitle: %@", selectedIndex, tabBar.selectedTabItem.title);		
		[self setStatusBarWith:[NSString stringWithFormat:@"Loading %@...", tabBar.selectedTabItem.title] andLoading:YES];

		TTTabItem *tabItem = tabBar.selectedTabItem;
		InterestCategory *interestCategory = tabItem.object;
		[self.pointOfInterestController getAllPointsOfInterestFromCategory:interestCategory];
	}
} 

/** Add a marker for the building that was tapped */
- (void) singleTapOnMap: (RMMapView*) map At: (CGPoint) point
{
	[self removeAllLabels];
	// Only in Search MODE
	if ([segmentedSearchDirections selectedSegmentIndex] == 0)
	{
		//NSLog(@"Going to Add Marker");
		CLLocationCoordinate2D coordinate = [self.mapView.contents
											 pixelToLatLong: point];
		Building *nearestBuilding = [self findNearestBuilding:coordinate];
		if (nearestBuilding)
		{
			[self removeAllBuildingMarkers];
			searchBar.text = @"";
			[self addMarkerForBuilding:nearestBuilding];
		}
		else 
		{
			[self removeAllBuildingMarkers];
		}
	}
	else
	{


		// this is to select buildings for directions by tapping on the map
		
		CLLocationCoordinate2D coordinate = [self.mapView.contents
											 pixelToLatLong: point];
		Building *nearestBuilding = [self findNearestBuilding:coordinate];
		if(nearestBuilding)
		{
			[self didSelectBuilding:nearestBuilding];
		}
		
	}

} 

/** a tap on Building markers opens the website, interest markers adds their label */
- (void) tapOnMarker:(RMMarker *)marker onMap:(RMMapView *)map
{
	id markerClass = marker.data;
	if ([markerClass isKindOfClass: [Building class]])
	{
		Building *building = markerClass;
		NetworkUtility *nUtil = [NetworkUtility sharedInstance]; 
		if ([nUtil startNetwork] == NotReachable) {
			[self showAlert:@"Sorry, we were unable to load certain Building information because an internet connection could not be found."];
		} 
		else
		{
			//TTOpenURL([NSString stringWithFormat:@"http://www.uh.edu/campus_map/buildings/%@.php", building.code]);
			TTOpenURL([NSString stringWithFormat:@"http://www.uh.edu/campus_map/buildings/%@.php", building.code]);
		}
	}
	else if ([markerClass isKindOfClass: [Interest class]])
	{
		Interest *interest = markerClass;
		[self removeAllLabels];
					
		if ([interest.category compare:@"Parking"] == 32)
		{
			NSLog(@"Parking!");
			//TTAlert(@"Parking Info for Lot %@:\n %@", interest.name, interest.description);
		}
		else 
		{
			[markerManager removeMarker:marker];
			marker = nil;
			[marker release];
			RMMarker *newMarker = [self addMarkerForInterest:interest];
			[newMarker setLabel:[self makeMarkerLabelWithTitle:interest.name andSubTitle:interest.description]];	
		}

	}
}

- (void) tapOnLabelForMarker: (RMMarker*) marker onMap: (RMMapView*) map 
{
	
	id markerClass = marker.data;
	if ([markerClass isKindOfClass: [Building class]])
	{
		[self tapOnMarker:marker onMap:map];
	}
	else 
	{
		Interest *interest = markerClass;
		if (interest.URL != nil && [interest.URL class] != [NSNull class] && [interest.URL length] > 6)
		{
			NetworkUtility *nUtil = [NetworkUtility sharedInstance]; 
			if ([nUtil startNetwork] == NotReachable) {
				   [self showAlert:@"Sorry, we were unable to load certain information because an internet connection could not be found."];
			} 
			else
			{
				TTOpenURL(interest.URL);
			}
		}
		else 
		{
			//CRASH
			//[self showAlert:interest.description];
		}
	}
}

/** Find the nearest building to the user touch, provided it's close enough to a building */
-(Building *)findNearestBuilding: (CLLocationCoordinate2D) coordinate {

	//NSLog(@"finding...");
	
	float dx, dy, distance, closestPoint;
	
	Building *nearestBuilding;
	closestPoint = 10000000;
	for (Building* building in buildings)
	{
		dx = building.latitude - coordinate.latitude;
		dy = building.longitude - coordinate.longitude;
		distance = sqrt(dx*dx + dy*dy);
		if (distance < closestPoint)
		{
			closestPoint = distance;
			nearestBuilding = building;
		}
	}
	//NSLog(@"the nearestBuilding is %@", nearestBuilding.name);
	
	if (closestPoint < 0.001)
	{
		return nearestBuilding;
	}
	else
	{
		return nil;
	}
}
/** Find the nearest interest to a building. Be sure to only call this after making an interest controller request */

- (Interest *)findNearestInterestToBuilding:(Building *)building
{
	float dx, dy, distance, closestPoint;
	Interest *nearestInterest;
	
	closestPoint = 10000000;
	for (Interest *interest in self.pointOfInterestController.pointsOfInterest)
	{
		dx = interest.latitude - building.latitude;
		dy = interest.longitude - building.longitude;
		distance = sqrt(dx*dx + dy*dy);
		if (distance < closestPoint)
		{
			closestPoint = distance;
			nearestInterest = interest;
		}
	}
	//NSLog(@"the nearestBuilding is %@", nearestBuilding.name);
	
	return nearestInterest;
	
}

#pragma mark -
#pragma mark Location manager
- (BOOL)findMyLocation
{	
	// If it's not possible to get a location, then return.
	CLLocation *location = [locationManager location];
	if (location)
	{
		myLocationCoordinates = [location coordinate];
		
		// Check to see if current location is outside of map boundary
		if ( !(myLocationCoordinates.latitude > 29.70926400 && myLocationCoordinates.latitude < 29.73183098) 
			 || !(myLocationCoordinates.longitude > -95.35534143 && myLocationCoordinates.longitude < -95.32478571) )
		{
			return NO;
		}

		myLocationBuilding.latitude = myLocationCoordinates.latitude;
		myLocationBuilding.longitude = myLocationCoordinates.longitude;
		
		return YES;
	}
	return NO;
}

- (void)locateMeOnMap:(id)sender
{

	if ([self findMyLocation])
	{

		[self removeAllClasslessMarkers];
		//NSLog(@"After Remove all Classless Makers");
		
		RMMarker *marker = [[RMMarker alloc]initWithKey:RMMarkerBlueKey];
		[marker replaceImage:[[UIImage imageNamed:@"marker_location.png"] CGImage] anchorPoint:CGPointMake(0.4,1.0)];
		
		// add this marker to the map using the marker manager
		[markerManager addMarker:marker AtLatLong:myLocationCoordinates];
		//can be released and accessed through the marker manager later
		[marker release];
		
		// Re-center map
		//NSLog(@"Move to lat and long");
		[self.mapView moveToLatLong:myLocationCoordinates];
		
		//NSLog(@"Distance in meters to building:%f", [self sphericalDistanceFromLat1:myLocationCoordinates.latitude Lon1:myLocationCoordinates.longitude toLat2:29.717353 Lon2:-95.34207]);
	}
	else
	{

		// Not in boundary
		UIAlertView *alertNotOnCampus = [[[UIAlertView alloc] initWithTitle:@"Not On Campus"
												   message:@"According to your GPS, you are currently not on campus!"
												   delegate:self cancelButtonTitle:@"Ok" 
												   otherButtonTitles:nil, nil] autorelease];
		[alertNotOnCampus show];
	}
}


/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}

/**  spherical distance in meters */
- (CGFloat)sphericalDistanceFromLat1: (CGFloat)lat1 Lon1: (CGFloat)lon1 toLat2: (CGFloat)lat2 Lon2: (CGFloat)lon2
{
	return acos(sin(lat1 * 0.0174533) * sin(lat2 * 0.0174533) + cos(lat1 * 0.0174533) 
				* cos(lat2 * 0.0174533) * cos((lon2-lon1) * 0.0174533)) * 6371000;
} 

- (void)showAlert:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message
																								 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

#pragma mark -
#pragma mark Close mapView

- (void)viewDidUnload {

	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	//NSLog(@"MAP VIEW: viewDidUnload");
}


- (void)dealloc 
{
	//[[Beacon shared] endSubBeaconWithName:@"mapView: Opened mapView"];
	[FlurryAPI endTimedEvent:@"mapView: Opened mapView"];

	self.searchBar.delegate = nil;
	self.resultsTableView.delegate = nil;
	self.mapView.delegate = nil;
	self.startBar.delegate = nil;
	self.destinationBar.delegate = nil;
	self.interestTabBar.delegate = nil;
	
	[mapView removeFromSuperview];
	self.mapView = nil;
	self.locationManager = nil;
	[locationManager release];
	self.buildingStart = nil;
	self.buildingEnd = nil;
	[myLocationBuilding release];

	[buildings release];
	[filteredBuildings release];	
	[resultsTableView release];
	[routePath release];
	[startBar release];
	[searchBar release];
	toolbar = nil;
	[toolbar release];
	if (self.interestTabBar)
	{
		self.interestTabBar.tabItems = nil;
	}
	self.interestTabBar = nil;
	[destinationBar release];
	[statusBarView release];
	[segmentedSearchDirections release];
	[pointOfInterestController release];
	interestCategoryController = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self 
										 name:@"LoadedPointsOfInterest"
										 object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
										  name:@"LoadedInterestCategories"
										  object:nil];	
	[super dealloc];
}


@end
