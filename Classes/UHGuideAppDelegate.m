//
//  UHGuideAppDelegate.m
//  UHGuide
//
//  Created by Andre Navarro on 9/24/10.
//  Copyright Squirrel Hero 2010. All rights reserved.
//

#import "UHGuideAppDelegate.h"
#import "FlurryAPI.h"

#import "LauncherViewController.h"
#import "MapViewController.h"
#import "WeatherViewsController.h"
#import "DirectoryViewController.h"
#import "GlobalStyleSheet.h"
#import "CreditsViewController.h"
#import "SettingsViewController.h"
#import "NetworkUtility.h"
#import "SearchPhotosViewController.h"
#import "FlurryAPI.h"
#import "PersonViewController.h"
#import "SocialLinksViewController.h"
#import "SocialCategoriesViewController.h"

@implementation UHGuideAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
   // [window makeKeyAndVisible];
	
	//[FlurryAPI startSession:@"4LQW47CIJQQIKTCD2D61"];
	
	
	[TTStyleSheet setGlobalStyleSheet:[[[GlobalStyleSheet alloc] init] autorelease]]; 
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.persistenceMode = TTNavigatorPersistenceModeNone; // ModeAll for persistance
	
	
	TTURLMap* map = navigator.URLMap;
	[map from:@"*" toViewController:[TTWebController class]];
	
	[map from:@"uh://launcher" toViewController:[LauncherViewController class]];
	[map from:@"uh://campusmap" toViewController:[MapViewController class]];
	[map from:@"uh://weather" toViewController:[WeatherViewsController class]];
	
	[map from:@"uh://people" toViewController:[DirectoryViewController class]];
	[map from:@"uh://person?" toViewController:[PersonViewController class]];
	
	[map from:@"uh://social" toViewController:[SocialCategoriesViewController class]];
	
	[map from:@"uh://social_links/(initWithCategory:)" toViewController:[SocialLinksViewController class]];
	[map from:@"uh://credits" toViewController:[CreditsViewController class]]; 
	[map from:@"uh://settings" toViewController:[SettingsViewController class]]; 
	[map from:@"uh://photos" toViewController:[SearchPhotosViewController class]]; 
	
	[map from:@"uh://dummy" toViewController:nil];
	
	//[navigator openURL:@"uh://launcher" animated:NO];
	TTOpenURL(@"uh://launcher");
	
	return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
	NetworkUtility *nUtil = [NetworkUtility sharedInstance];
	[nUtil startNetwork];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
