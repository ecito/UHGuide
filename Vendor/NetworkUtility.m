//
//  NetworkUtility.m
//  LocateThem
//
//  Created by Henri Asseily on 4/3/09.
/*
 Copyright (c) 2008-2009, Telnic Ltd. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Telnic Ltd. nor the names of its contributors may be used to endorse or
 promote products derived from this software without specific prior written permission.
 THIS DOCUMENTATION IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
 OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//

#import "NetworkUtility.h"

static NetworkUtility *sharedNetworkUtility = nil;

@implementation NetworkUtility

@synthesize remoteHostStatus;
@synthesize internetConnectionStatus;

#pragma mark ------ init

- (id) init {
	self = [super init];
	networkActivityCounter = 0;
	return self;
}

- (void) dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

#pragma mark ------ network methods

- (void)networkwillActivate:(BOOL)activate {
	if (activate) {
		networkActivityCounter++;
	} else {
		networkActivityCounter--;
	}
	//NSLog(@"Network activity counter: %d", networkActivityCounter);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(networkActivityCounter > 0)];
}

- (NetworkStatus)startNetwork {
	// Hack to force start the networking (wifi or edge/3G)
	NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
	[urlReq setHTTPMethod:@"HEAD"];
	[self networkwillActivate:YES];
	NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:urlReq delegate:self startImmediately:YES] autorelease];
	[self networkwillActivate:NO];
	if (!theConnection) {
		return NotReachable;
	}
	
	[[Reachability sharedReachability] setAddress:@"208.67.222.222"];
	[self updateStatus];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name:@"kNetworkReachabilityChangedNotification"
											   object:nil];
	return self.remoteHostStatus;
}

- (void)reachabilityChanged:(NSNotification *)note {
	[self updateStatus];
}

- (void)updateStatus {
    self.remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
    self.internetConnectionStatus = [[Reachability sharedReachability] internetConnectionStatus];
	//NSLog(@"Reachability changed, values are: %d - %d", remoteHostStatus, internetConnectionStatus);
}

#pragma mark ---- singleton object methods ----

// See "Creating a Singleton Instance" in the Cocoa Fundamentals Guide for more info

+ (NetworkUtility *)sharedInstance {
    @synchronized(self) {
        if (sharedNetworkUtility == nil) {
            [[[self alloc] init] autorelease];  // autorelease (does nothing) to avoid clang warning
        }
    }
    return sharedNetworkUtility;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedNetworkUtility == nil) {
            sharedNetworkUtility = [super allocWithZone:zone];
            return sharedNetworkUtility;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    // do nothing
}

- (id)autorelease {
    return self;
}

@end
