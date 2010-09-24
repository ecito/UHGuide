//
//  LabsAppDelegate.m
//  Labs
//
//  Created by Andre Navarro on 1/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SocialCategoriesDataSource.h"
#import "JSON.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SocialCategoriesModel

@synthesize allSocialCategories = _allSocialCategories;


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject


- (void)dealloc {
  TT_RELEASE_SAFELY(_delegates);
  TT_RELEASE_SAFELY(_allSocialCategories);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if( !self.isLoading) {
    NSString* url = @"http://uhcamp.us.to/social_categories";
										
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
  //NSLog(@"responseBody: %@", responseBody);
	
	// Parse the JSON data that we retrieved from the server.
	NSMutableArray *results = [responseBody JSONValue];
	[responseBody release];
	
	if (results) {
		TT_RELEASE_SAFELY(_allSocialCategories);
		_allSocialCategories = [[NSArray alloc] initWithArray:results copyItems:YES];
	}
	// NSLog(@"results: %@", [results objectForKey:@"menu_item"]);
	
	
  [super requestDidFinishLoad:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public



@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SocialCategoriesDataSource

@synthesize socialCategoriesModel = _socialCategoriesModel;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _socialCategoriesModel = [[SocialCategoriesModel alloc] init];
    self.model = _socialCategoriesModel;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_socialCategoriesModel);
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
  
  //NSLog(@"all: %@", _socialCategoriesModel.allSocialCategories);
  for (NSDictionary *socialCategoryDict in _socialCategoriesModel.allSocialCategories) {

		NSDictionary *socialCategory = [socialCategoryDict objectForKey:@"social_category"];
			
		if ([socialCategory objectForKey:@"title"] != [NSNull null])
		{
			NSString *name = [socialCategory objectForKey:@"title"];
			NSString *category_id = [socialCategory objectForKey:@"id"];
			NSString *URL = [NSString stringWithFormat:@"uh://social_links/%@", category_id];
			
			[_items addObject:[TTTableTextItem itemWithText:name URL:URL]];
			
		}
  }
	
}

@end