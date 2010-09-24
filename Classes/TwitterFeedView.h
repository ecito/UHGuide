//
//  TwitterFeedView.h
//  CoffeeGroundz
//
//  Created by Andre Navarro on 2/2/10.
//  Copyright 2010 Squirrel Hero All rights reserved.
//

#import <Three20/Three20.h>
#import <QuartzCore/QuartzCore.h>

@protocol TwitterFeedViewDelegate

-(void)twitterFeedViewUpdateSuccessful;
-(void)twitterFeedViewUpdateFailed;

@end

@interface TwitterFeedView : TTView  <TTURLRequestDelegate, TTURLResponse> {

	NSMutableData *responseData;
	TTURLRequest *urlRequest;
	id <TwitterFeedViewDelegate>delegate;
}

@property(nonatomic,retain)TTURLRequest *urlRequest;
@property(nonatomic,assign)id delegate;

-(void)addStuffToView;
-(void)searchTwitter:(NSString *)twitterURL;
-(void)addTwitterText:(NSString*)text;
- (void)transitionFromBottomUp;


@end
