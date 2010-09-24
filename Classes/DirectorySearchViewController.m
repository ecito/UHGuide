//
//  DirectorySearchViewController.m
//  UHGuide
//
//  Created by Andre Navarro on 7/27/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import "DirectorySearchViewController.h"


@implementation DirectorySearchViewController

@synthesize delegate;

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	if (delegate != nil && [delegate respondsToSelector:@selector(directorySearchViewController:didSelectObject:atIndexPath:)]) {
		[delegate directorySearchViewController:self didSelectObject:object atIndexPath:indexPath];
	}
}

@end
