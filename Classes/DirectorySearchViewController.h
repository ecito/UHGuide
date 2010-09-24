//
//  DirectorySearchViewController.h
//  UHGuide
//
//  Created by Andre Navarro on 7/27/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import <Three20/Three20.h>

@class DirectorySearchViewController;

@protocol DirectorySearchViewControllerDelegate <NSObject>

- (void)directorySearchViewController:(DirectorySearchViewController*)controller didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end

@interface DirectorySearchViewController : TTTableViewController {
	id<DirectorySearchViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id delegate;

@end


