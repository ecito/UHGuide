#import <Three20/Three20.h>

@protocol DirectoryControllerDelegate;
@class LDAPDataSource;

@interface DirectoryViewController : TTTableViewController <TTSearchTextFieldDelegate> {
  id<DirectoryControllerDelegate> _delegate;
}

@property(nonatomic,assign) id<DirectoryControllerDelegate> delegate;

@end

