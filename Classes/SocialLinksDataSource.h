//
//  LabsAppDelegate.m
//  Labs
//
//  Created by Andre Navarro on 1/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <Three20/Three20.h>

@interface SocialLinksModel : TTURLRequestModel {
  NSArray* _allSocialLinks;
	NSString *_category;
	
}
@property (nonatomic, copy) NSString* category;
@property(nonatomic,retain) NSArray* allSocialLinks;

@end

@interface SocialLinksDataSource : TTSectionedDataSource {
  SocialLinksModel* _socialLinksModel;
}

@property(nonatomic,readonly) SocialLinksModel* socialLinksModel;

@end