//
//  LabsAppDelegate.m
//  Labs
//
//  Created by Andre Navarro on 1/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SocialLinksDataSource.h"
#import "JSON.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SocialLinksModel

@synthesize allSocialLinks = _allSocialLinks, category = _category;


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithCategory:(NSString*)aCategory{
  if (self = [super init]) {
    _delegates = nil;
		_category = aCategory;
  }
  return self;
}


- (void)dealloc {
  TT_RELEASE_SAFELY(_delegates);
  TT_RELEASE_SAFELY(_allSocialLinks);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if( !self.isLoading && TTIsStringWithAnyText(_category) ) {
    NSString* url = [NSString stringWithFormat:@"http://uhcamp.us.to/social_categories/%@/social_links", _category];
		
		NSLog(@"connecting to: %@", url);
    TTURLRequest* request = [TTURLRequest
														 requestWithURL: url
														 delegate: self];
		
    id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
    request.response = response;
		request.cachePolicy = TTURLRequestCachePolicyNone;
    TT_RELEASE_SAFELY(response);
		
    [request send];
  }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLDataResponse* response = request.response;
	
  NSString* responseBody = [[NSString alloc] initWithData: response.data
																								 encoding: NSUTF8StringEncoding];	
	// Parse the JSON data that we retrieved from the server.
	NSMutableArray *results = [responseBody JSONValue];
	[responseBody release];
	
	if (results) {
		TT_RELEASE_SAFELY(_allSocialLinks);
		_allSocialLinks = [[NSArray alloc] initWithArray:results copyItems:YES];
	}
	
  [super requestDidFinishLoad:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public



@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SocialLinksDataSource

@synthesize socialLinksModel = _socialLinksModel;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithCategory:(NSString*)aCategory{
  if (self = [super init]) {
    _socialLinksModel = [[SocialLinksModel alloc] initWithCategory:aCategory];
    self.model = _socialLinksModel;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_socialLinksModel);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  //return [TTTableViewDataSource lettersForSectionsWithSearch:NO summary:NO];
	return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];
  self.sections = [NSMutableArray array];
  
  NSMutableDictionary* groups = [NSMutableDictionary dictionary];
  for (NSDictionary *linkDict in _socialLinksModel.allSocialLinks) {

		NSDictionary *linkItem = [linkDict objectForKey:@"social_link"];
		NSLog(@"link: %@", linkDict);	
		if ([linkItem objectForKey:@"title"] != [NSNull null])
		{
			NSString *title = [linkItem objectForKey:@"title"];
			NSString *URL = [linkItem objectForKey:@"url"];
			NSString *imageURL = [linkItem objectForKey:@"icon"];
			NSString *letter = ([linkItem objectForKey:@"network"] == [NSNull null]) ? @" " : [NSString stringWithFormat:@"%@", [linkItem objectForKey:@"network"]];
			letter = [letter capitalizedString];
			NSMutableArray* section = [groups objectForKey:letter];
			if (!section) {
				section = [NSMutableArray array];
				[groups setObject:section forKey:letter];
			}
			
			[section addObject:[TTTableImageItem itemWithText:title imageURL:imageURL URL:URL]];

		}
  }
	
	NSArray* letters = [groups.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (NSString* letter in letters) {
    NSArray* items = [groups objectForKey:letter];
    [_sections addObject:letter];
    [_items addObject:items];
  }

}


@end