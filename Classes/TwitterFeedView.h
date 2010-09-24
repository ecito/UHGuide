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
	TTStyledTextLabel* tweetLabel;
	id <TwitterFeedViewDelegate>delegate;
}

@property(nonatomic,retain)TTURLRequest *urlRequest;
@property(nonatomic,assign)id delegate;
@property(nonatomic, retain) TTStyledTextLabel* tweetLabel;
-(void)addStuffToView;
-(void)searchTwitter;
-(void)addTwitterText:(NSString*)text;
- (void)transitionFromBottomUp;


@end
