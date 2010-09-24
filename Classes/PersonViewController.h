//
//  PersonViewController.h
//  UHGuide
//
//  Created by Andre Navarro on 7/26/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import <Three20/Three20.h>
#import "Person.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface PersonViewController : ABUnknownPersonViewController {

	Person *person;
}

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;


@end
