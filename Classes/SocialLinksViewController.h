//
//  SocialLinksViewController.h
//  UHGuide
//
//  Created by Andre Navarro on 8/30/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import <Three20/Three20.h>


@interface SocialLinksViewController : TTTableViewController {
	NSString* category;
}

@property (nonatomic, copy) NSString* category;

@end
