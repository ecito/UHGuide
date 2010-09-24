//
//  LabsAppDelegate.m
//  Labs
//
//  Created by Andre Navarro on 1/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <Three20/Three20.h>

@interface SocialCategoriesModel : TTURLRequestModel {
  NSArray* _allSocialCategories;
	
}
@property(nonatomic,retain) NSArray* allSocialCategories;

@end

@interface SocialCategoriesDataSource : TTListDataSource {
  SocialCategoriesModel* _socialCategoriesModel;
}

@property(nonatomic,readonly) SocialCategoriesModel* socialCategoriesModel;

@end
