//
//  Person.m
//  UHGuide
//
//  Created by Andre Navarro on 7/25/10.
//  Copyright 2010 University of Houston. All rights reserved.
//

#import "Person.h"


@implementation Person

@synthesize affiliation;
@synthesize firstName;
@synthesize lastName;
@synthesize mail;
@synthesize title;
@synthesize roomNumber;
@synthesize buildingName;
@synthesize telephoneNumber;

- (id)initWithLDAPDictionary:(NSDictionary*)personDict {
	if (self = [super init]) {
		
		if ([personDict objectForKey:@"affiliation"] != nil && [[personDict objectForKey:@"affiliation"] count]) {
			self.affiliation = [[personDict objectForKey:@"affiliation"] objectAtIndex:0];
		}
		if ([personDict objectForKey:@"givenname"] != nil && [[personDict objectForKey:@"givenname"] count]) {
			self.firstName = [[personDict objectForKey:@"givenname"] objectAtIndex:0];
		}
		if ([personDict objectForKey:@"sn"] != nil && [[personDict objectForKey:@"sn"] count]) {
			self.lastName = [[personDict objectForKey:@"sn"] objectAtIndex:0];
		}
		if ([personDict objectForKey:@"mail"] != nil && [[personDict objectForKey:@"mail"] count]) {
			self.mail = [[personDict objectForKey:@"mail"] objectAtIndex:0];
		}
		if ([personDict objectForKey:@"title"] != nil && [[personDict objectForKey:@"title"] count]) {
			self.title = [[personDict objectForKey:@"title"] objectAtIndex:0];
		}
		if ([personDict objectForKey:@"roomnumber"] != nil && [[personDict objectForKey:@"roomnumber"] count]) {
			self.roomNumber = [[personDict objectForKey:@"roomnumber"] objectAtIndex:0];
		}
		if ([personDict objectForKey:@"buildingname"] != nil && [[personDict objectForKey:@"buildingname"] count]) {
			self.buildingName = [[personDict objectForKey:@"buildingname"] objectAtIndex:0];
		}
		if ([personDict objectForKey:@"telephonenumber"] != nil && [[personDict objectForKey:@"telephonenumber"] count]) {
			self.telephoneNumber = [[personDict objectForKey:@"telephonenumber"] objectAtIndex:0];
		}
		
	}
	
	return self;
}

- (ABRecordRef)record {
	
	ABRecordRef result = ABPersonCreate();
	CFErrorRef anError = NULL;
	
	if (self.firstName.length) {
		ABRecordSetValue(result, kABPersonFirstNameProperty, self.firstName, &anError);
	}
	if (self.lastName.length) {
		ABRecordSetValue(result, kABPersonLastNameProperty, self.lastName, &anError);
	}
	if ([self address]) {
		ABRecordSetValue(result, kABPersonNoteProperty, [self address], &anError);
	}
	if (self.title.length) {
		ABRecordSetValue(result, kABPersonJobTitleProperty, self.title, &anError);
	}
	if (self.telephoneNumber) {
		ABMutableMultiValueRef multiPhoneRef = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiPhoneRef, self.telephoneNumber, kABPersonPhoneMainLabel, NULL);
		ABRecordSetValue(result, kABPersonPhoneProperty, multiPhoneRef, &anError);
		CFRelease(multiPhoneRef);
	}
	if (self.mail) {
		ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiEmail, self.mail, kABWorkLabel, NULL);
		ABRecordSetValue(result, kABPersonEmailProperty, multiEmail, &anError);
		CFRelease(multiEmail);
	}
	
	return result;
}


- (id)initWithJSONDictionary:(NSDictionary*)personDict {
	if (self = [super init]) {
		
		self.affiliation = ([[personDict objectForKey:@"affiliation"] class] == [[NSNull null] class]) ? nil : [personDict objectForKey:@"affiliation"];
		self.lastName = ([[personDict objectForKey:@"sn"] class] == [[NSNull null] class]) ? nil : [personDict objectForKey:@"sn"];
		self.firstName = ([[personDict objectForKey:@"givenname"] class] == [[NSNull null] class]) ? nil : [personDict objectForKey:@"givenname"];
		self.mail = ([[personDict objectForKey:@"mail"] class] == [[NSNull null] class]) ? nil : [personDict objectForKey:@"mail"];
		self.title = ([[personDict objectForKey:@"title"] class] == [[NSNull null] class]) ? nil : [personDict objectForKey:@"title"];
		self.roomNumber = ([[personDict objectForKey:@"roomnumber"] class] == [[NSNull null] class]) ? nil : [personDict objectForKey:@"roomnumber"];
		self.buildingName = ([[personDict objectForKey:@"buildingname"] class] == [[NSNull null] class]) ? nil : [personDict objectForKey:@"buildingname"];
		self.telephoneNumber = ([[personDict objectForKey:@"telephonenumber"] class] == [[NSNull null] class]) ? nil : [personDict objectForKey:@"telephonenumber"];
		
		[self.lastName retain];
		[self.firstName retain];
		
	}
	return self;
}

- (NSString*)name {
	return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
	
}

- (NSString*)title {
	if (title.length) {
		return [NSString stringWithFormat:@"%@: %@", self.affiliation, title ];
	} else {
		return self.affiliation;
 }
}

- (NSString*)address {
	if (self.buildingName != nil && self.roomNumber != nil && self.buildingName.length && self.roomNumber.length) {
		return [NSString stringWithFormat:@"%@ %@", self.buildingName, self.roomNumber];
	} else {
		return nil;
	}
}

- (NSString*)description {
	return [NSString stringWithFormat:@"Name: %@ %@, affiliation: %@", self.firstName, self.lastName, self.affiliation];
}

@end
