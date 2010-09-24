//
//  Person.h
//  UHGuide
//
//  Created by Andre Navarro on 7/25/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <Three20/Three20.h>

/*
 dude = {"affiliation" => entry["affiliation"][0],
 "givenname" => entry["givenname"][0],
 "sn" => entry["sn"][0],
 "mail" => entry["mail"][0],
 "title" => entry["title"][0],
 "roomnumber" => entry["roomnumber"][0],
 "buildingname" => entry["buildingname"][0],
 "telephonenumber" => entry["telephonenumber"][0]
 }
 */

@interface Person : TTTableTextItem {

	NSString *affiliation;
	NSString *firstName;
	NSString *lastName;
	NSString *mail;
	NSString *title;
	NSString *roomNumber;
	NSString *buildingName;
	NSString *telephoneNumber;
}

@property (nonatomic, retain) NSString *affiliation;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *mail;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *roomNumber;
@property (nonatomic, retain) NSString *buildingName;
@property (nonatomic, retain) NSString *telephoneNumber;

- (id)initWithJSONDictionary:(NSDictionary*)personDict;

- (ABRecordRef)record;
- (NSString*)name;
- (NSString*)title;
- (NSString*)address;

@end
