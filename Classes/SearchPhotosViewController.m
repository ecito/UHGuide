//
//  SearchPhotosViewController.m
//

#import "SearchPhotosViewController.h"
#import "SearchResultsPhotoSource.h"
#import "SearchResultsModel.h"
#import "FlurryAPI.h"

@implementation SearchPhotosViewController

- (id)init
{
	if (self = [super init])
	{
			[TTURLRequestQueue mainQueue].maxContentLength = 0;
			photoSource = [[SearchResultsPhotoSource alloc] initWithModel:CreateSearchModelWithCurrentSettings()];
			[photoSource load:TTURLRequestCachePolicyDefault more:NO];
			TTThumbsViewController *thumbs = [[TTThumbsViewController alloc] init];
			[thumbs setPhotoSource:photoSource];
			thumbs.model = [photoSource underlyingModel];
			self = thumbs;
			//self.title = @"Flickr Photos";
			//[[Beacon shared] startSubBeaconWithName:@"photos: opened Photos" timeSession:NO];
			[FlurryAPI logEvent:@"photos: opened Photos"];
		
			// this is some crazy init but it's the only way I could get it to work
			// there's no way to change the color of the status bar without messing it up
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc photos"); //wtf this gets called right after loading but everything still works fine
    [photoSource release];
    [super dealloc];
}


@end
