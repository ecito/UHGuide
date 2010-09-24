#import <Three20/Three20.h>
#import <CoreLocation/CoreLocation.h>
#import "TwitterFeedView.h"
@protocol FBSessionDelegate;


@interface LauncherViewController : TTViewController <TTLauncherViewDelegate, TwitterFeedViewDelegate, FBSessionDelegate>  {
  TTLauncherView* _launcherView;
	UIActivityIndicatorView *twitterFeedActivityIndicator;
	TTImageView *uhPres;
	UILabel *uhPresLabel;
}

- (void)updateBadgeNumber:(NSNotification *)notification;
- (void)openCreditsView:(id)sender;
- (BOOL)deviceHasCompass;

@end
