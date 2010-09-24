#import "Person.h"
#import "DirectoryDataSource.h"
#import "PersonTableItem.h"

#define kDirectorySearchURL @"http://uhcamp.us.to/people/search"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation DirectoryModel

@synthesize people;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {

		searchQuery = nil;
		affiliation = nil;
    people = [[NSMutableArray array] retain];

  }
  return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(searchQuery);
  TT_RELEASE_SAFELY(affiliation);
  TT_RELEASE_SAFELY(people);
  [super dealloc];
}


- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
// NSLog(@"load");

	
  if (!self.isLoading && TTIsStringWithAnyText(searchQuery)) {
	// NSLog(@"loading...");
		
//		NSString* filteredSearchQuery = [[searchQuery componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];

//		NSMutableCharacterSet *set = [NSCharacterSet letterCharacterSet];
//		[set formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
//
//		NSString* filteredSearchQuery = [[searchQuery componentsSeparatedByCharactersInSet:[set invertedSet]] componentsJoinedByString:@""];
		NSString *escapedSearchQuery = [searchQuery stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	// NSLog(@"filtered: %@", escapedSearchQuery);
		
		NSString* url = [NSString stringWithFormat:kDirectorySearchURL, escapedSearchQuery, affiliation];

		
    request = [TTURLRequest
							 requestWithURL: url
							 delegate: self];
		
		[request retain];
											
		[request.parameters setObject:escapedSearchQuery forKey:@"name"];
		if (affiliation) {
			[request.parameters setObject:affiliation forKey:@"affiliation"];
		}
    request.cachePolicy = TTURLRequestCachePolicyNone;
		
		request.httpMethod = @"PUT";
		
		
    id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);		
		
    [request send];
  }
}

- (void)requestDidFinishLoad:(TTURLRequest*)req {
	TTURLDataResponse* response = req.response;

	NSString *responseString = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	
	//NSLog(@"response: %@", responseString );

	NSArray *peeps = [responseString JSONValue];

	[people removeAllObjects];

	for (NSDictionary *peep in peeps) {
		Person *person = [[Person alloc] initWithJSONDictionary:[peep objectForKey:@"person"]];
		[people addObject:person];
	}
	
  [super requestDidFinishLoad:req];
}


- (void)cancel {
	
	if (request != nil && [request class] == [TTURLRequest class] && request.isLoading) {
		[request cancel];
		request = nil;
	}
	[_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)search:(NSString*)text {
}

- (void)search:(NSString*)text withinScope:(NSString*)scope {
	
	[self cancel];
// NSLog(@"searching: %@", text);
	
  if (text.length > 3) {
		searchQuery = [text copy];
		affiliation = scope;
		
		[self load:TTURLRequestCachePolicyNone more:NO];
  }
}

/* 

 //for direct LDAP searching... wrap this around an NSOperation or thread or something 
-(void)searchLDAP:(NSString*)query affiliationOrNil:(NSString*)aff {
	NSArray* search_result;
	NSError* searchError;
// NSLog(@"Hello!");
	
	RHLDAPSearch *mySearch = [[RHLDAPSearch alloc] initWithURL:@"ldap://directory.uh.edu/"];
	search_result = [mySearch searchWithQuery:@"(&(cn=*paris*)(affiliation=Faculty))" withinBase:@"o=University of Houston" usingScope:RH_LDAP_SCOPE_SUBTREE error:&searchError];
	
// NSLog(@"search: %@", search_result);
	if ( search_result == nil ) {
	// NSLog(@"Search error: %@", [[searchError userInfo] valueForKey:@"err_msg"]);
	}
	
	[mySearch release];
}
*/

@end


///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation DirectorySearchDataSource

@synthesize directory;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return [TTTableViewDataSource lettersForSectionsWithSearch:YES summary:NO];
}

- (id)init {
  if (self = [super init]) {
    directory = [[DirectoryModel alloc] init];
    self.model = directory;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(directory);
  [super dealloc];
}
  
- (void)directorySearchViewController:(DirectorySearchViewController*)controller didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	
	NSDictionary *query = [NSDictionary dictionaryWithObject:[(PersonTableItem*)object person] forKey:@"person"];
	[[TTNavigator navigator] openURLAction:
	 [[[TTURLAction actionWithURLPath:@"uh://person"]
		 applyQuery:query]
		applyAnimated:YES]
	 ];
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];
  self.sections = [NSMutableArray array];
	
// NSLog(@"people: %@", directory.people);
  NSMutableDictionary* groups = [NSMutableDictionary dictionary];
  for (Person* person in directory.people) {
    NSString* letter = [NSString stringWithFormat:@"%c", [person.lastName characterAtIndex:0]];
    NSMutableArray* section = [groups objectForKey:letter];
    if (!section) {
      section = [NSMutableArray array];
      [groups setObject:section forKey:letter];
    }
		
    PersonTableItem* item = [PersonTableItem itemWithPerson:person];
    [section addObject:item];
  }
	
  NSArray* letters = [groups.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (NSString* letter in letters) {
    NSArray* items = [groups objectForKey:letter];
    [_sections addObject:letter];
    [_items addObject:items];
  }
}

- (void)search:(NSString*)text {
  [directory search:text];
}

- (void)search:(NSString*)text withinScope:(NSString*)scope {
// NSLog(@"Scope %@", scope);
	if ([scope isEqualToString:@"All"]) {
		[directory search:text withinScope:nil];
	} else {
		[directory search:text withinScope:scope];
	}
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id) object { 
	if ([object class] == [PersonTableItem class]) {
		return [TTTableSubtitleItemCell class];
	} else {
		return [super tableView:tableView cellClassForObject:object];
	}
}

- (NSString*)titleForLoading:(BOOL)reloading {
  return @"Searching...";
}

- (NSString*)titleForNoData {
  return @"No results found";
}

- (NSString*)titleForEmpty {
  return @"No results found";
}

- (NSString*)titleForError:(NSError*)error {
  return @"Sorry, there was an error";
}

@end
