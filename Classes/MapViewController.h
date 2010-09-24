//
//  ProgrammaticMapViewController.h
//  ProgrammaticMap
//
//  Created by Campus Guide on 9/25/09.
//  Copyright University of Houston 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>

#import "RMMapView.h"
#import "RMPath.h"
#import "Building.h"
#import "Interest.h"
#import "InterestCategory.h"
#import "PointOfInterestController.h"
#import "InterestCategoryController.h"
#import "JSON.h"

@class RMMapView, RMMarker, RMMarkerManager;

@interface MapViewController : UIViewController <RMMapViewDelegate,
															UITableViewDelegate, 
															UITableViewDataSource, 
															UISearchBarDelegate, 
															CLLocationManagerDelegate,
															TTTabDelegate>  {
	// Route-Me
	RMMapView *mapView;
	RMMarkerManager *markerManager;
	RMPath *routePath;

	CLLocationManager *locationManager; /**< Singleton locationManager */
	CLLocationCoordinate2D myLocationCoordinates; /**< Contains user's coordinates after clicking button */
	Building *myLocationBuilding; /**< User's location in a Building to use in search list */
																
	CLLocationCoordinate2D northWestCoverage; /**< Top-left corner of DB map */
	CLLocationCoordinate2D southEastCoverage; /**< Bottom-right corner of DB map */

	CLLocationCoordinate2D centerOfCoverage; /**< Center of DB map */
	CLLocationCoordinate2D centerOfMap; /**< For bounding the scrolling of the map */
	CLLocationCoordinate2D previousMapCenter; /**< For bounding the scrolling of the map */
	

	// Table objects
	NSMutableArray *buildings;	/**< Contains all Building objects loaded from DB */
	NSMutableArray *filteredBuildings; /**< Contains Buildings matched by the searchBar */
	
	UITableView *resultsTableView; /**< Displays the search results */
	UISearchBar *searchBar; /**< For searching of buildings */
	UISearchBar *startBar; /**< For searching the start building in direction mode */
	UISearchBar *destinationBar; /**< For searching the end building in direction mode */
	UIToolbar *toolbar; /**< Toolbar at the bottom */
	TTTabBar* interestTabBar; /**< Shows the categories after pulling them from the server */
	
	UISegmentedControl *segmentedSearchDirections; /**< Search | Directions */
		
	// Directions
	Building *buildingStart;
	Building *buildingEnd;

	UIView *statusBarView;
	
	PointOfInterestController *pointOfInterestController; /**< Pulls POIs for a particular category from server */
	InterestCategoryController *interestCategoryController; /**< Pulls categories from server */	
}

@property(nonatomic,retain)RMMapView *mapView;

@property(nonatomic,retain)PointOfInterestController *pointOfInterestController;
@property(nonatomic,retain)InterestCategoryController *interestCategoryController;

@property (nonatomic, assign) CLLocationCoordinate2D northWestCoverage;
@property (nonatomic, assign) CLLocationCoordinate2D southEastCoverage;
@property (nonatomic, assign) CLLocationCoordinate2D centerOfCoverage;
@property (nonatomic, assign) CLLocationCoordinate2D centerOfMap;
@property (nonatomic, assign) CLLocationCoordinate2D previousMapCenter;

@property(nonatomic,retain)UISearchBar *searchBar;
@property(nonatomic,retain)UISearchBar *startBar;
@property(nonatomic,retain)UISearchBar *destinationBar;
@property(nonatomic,retain)TTTabBar* interestTabBar;


@property(nonatomic,retain)RMPath *routePath;
@property(nonatomic,assign)UITableView *resultsTableView;
@property(nonatomic,retain)NSMutableArray *filteredBuildings;
@property(nonatomic,assign)RMMarkerManager *markerManager;

@property (nonatomic, retain)UISegmentedControl *segmentedSearchDirections;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D myLocationCoordinates;
@property (nonatomic, retain) Building *myLocationBuilding;

@property(nonatomic,retain) Building *buildingStart;
@property(nonatomic,retain) Building *buildingEnd;

@property(nonatomic,retain) UIView *statusBarView;

// Functions
- (void)loadBuildingsFromDatabase;
- (void)loadedPointsOfInterest:(NSNotification *)notification;
- (void)loadedInterestCategories:(NSNotification *)notification;

- (UIView *)makeMarkerLabelWithTitle:(NSString *)title andSubTitle:(NSString *)subTitle;
- (void)addMarkerForBuilding:(id)aBuilding withMarkerIcon:(NSString *)anIcon;
- (void)addMarkerForBuilding:(id)aBuilding;
- (RMMarker*)addMarkerForInterest:(id)aInterest;

- (Building *)findNearestBuilding:(CLLocationCoordinate2D) coordinate;
- (Interest *)findNearestInterestToBuilding:(Building *)building;

- (void)removeAllLabels;
- (void)removeAllBuildingMarkers;
- (void)removeAllInterestMarkers;
- (void)removeAllClasslessMarkers;

- (void)searchDirections:(id)sender;
- (void)switchBetweenSearchAndDirectionsMode:(NSInteger)switchTo;
- (void)didSelectBuilding:(Building *)building;
- (void)calculateDirections;


- (BOOL)findMyLocation;
- (void)locateMeOnMap:(id)sender;

- (void)setStatusBarWith:(NSString *)text andLoading:(BOOL)loading;

- (void)tabBar:(TTTabBar*)tabBar tabSelected:(NSInteger)selectedIndex;
- (CGFloat)sphericalDistanceFromLat1:(CGFloat)lat1 Lon1:(CGFloat)lon1 toLat2: (CGFloat)lat2 Lon2: (CGFloat)lon2;

@end