
#import "DirectoryViewController.h"
#import "DirectoryDataSource.h"


@implementation DirectoryViewController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    
    self.title = @"Directory";
    self.dataSource = [[[TTListDataSource alloc] init] autorelease];
  }
  return self;
}

- (void)dealloc {
	
	_delegate = nil;
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  DirectorySearchViewController* searchController = [[[DirectorySearchViewController alloc] init] autorelease];
	
  searchController.dataSource = [[[DirectorySearchDataSource alloc] init] autorelease];
	searchController.delegate = searchController.dataSource;
	
	
  self.searchViewController = searchController;
  self.tableView.tableHeaderView = _searchController.searchBar;
	_searchController.pausesBeforeSearching = YES;
	self.tableView.scrollEnabled = NO;
	
	NSArray *buttonTitles = [NSArray arrayWithObjects:@"All", @"Faculty", @"Students", @"Staff", nil];
	_searchController.searchBar.scopeButtonTitles = buttonTitles;
}

@end
