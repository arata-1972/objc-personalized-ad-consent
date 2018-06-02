//
//  Common.h
//  PersonalizedAdConsentSample
//
//  Created by Dolice on 2018/06/03.
//  Copyright © 2018 Dolice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PersonalizedAdConsent/PersonalizedAdConsent.h>

#define UD_PERSONALIZED_ADS_KEY @"UD_PERSONALIZED_ADS_KEY"

@interface Common : UIView {
    NSUserDefaults *userDefaults;
    BOOL           usePersonalizedAds;
}

#pragma mark - property
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, assign) BOOL           usePersonalizedAds;

#pragma mark - public method
+ (Common *)sharedManager;
- (void)setPersonalizedAdsSetting:(BOOL)usePersonalizedAds;
- (BOOL)isRequestLocationInEEAOrUnknown;
- (void)initPersonalizedAdsSetting;

@end
