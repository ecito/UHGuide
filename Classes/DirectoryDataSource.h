#import <Three20/Three20.h>
#import "DirectorySearchViewController.h"

@interface DirectoryModel : TTURLRequestModel {

  NSMutableArray* people;
	NSString *searchQuery;
	NSString *affiliation;
  NSArray* _allNames;
	
	TTURLRequest* request;
}

@property(nonatomic,retain) NSMutableArray* people;

- (void)search:(NSString*)text;
- (void)search:(NSString*)text withinScope:(NSString*)scope;

@end

@interface DirectorySearchDataSource : TTSectionedDataSource <DirectorySearchViewControllerDelegate> {
  DirectoryModel* directory;
}

@property(nonatomic,readonly) DirectoryModel* directory;

@end
