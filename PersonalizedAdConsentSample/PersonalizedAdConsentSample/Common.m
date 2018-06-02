//
//  Common.m
//  PersonalizedAdConsentSample
//
//  Created by Dolice on 2018/06/03.
//  Copyright © 2018 Dolice. All rights reserved.
//

#import "Common.h"

@implementation Common

@synthesize userDefaults;
@synthesize usePersonalizedAds;

#pragma mark - Shared Manager

static Common *_sharedInstance = nil;

+ (Common *)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[Common alloc] init];
    }
    
    return _sharedInstance;
}

#pragma mark - Personalized Ads

// 広告のパーソナライズ設定初期化
- (void)initPersonalizedAdsSetting
{
    // ユーザーデフォルト初期化
    NSMutableDictionary *personalizedAdsDefaults = [[NSMutableDictionary alloc] init];
    [personalizedAdsDefaults setValue:@YES forKey:UD_PERSONALIZED_ADS_KEY];
    [Common sharedManager].userDefaults = [NSUserDefaults standardUserDefaults];
    [[Common sharedManager].userDefaults registerDefaults:personalizedAdsDefaults];
    
    // 広告のパーソナライズ設定をユーザーデフォルトから保持
    [Common sharedManager].usePersonalizedAds = [[Common sharedManager].userDefaults boolForKey:UD_PERSONALIZED_ADS_KEY];
}

// 広告のパーソナライズ設定保持
- (void)setPersonalizedAdsSetting:(BOOL)usePersonalizedAds
{
    // 広告のパーソナライズ設定保持
    [Common sharedManager].usePersonalizedAds = usePersonalizedAds;
    
    // ユーザーデフォルト更新
    [[Common sharedManager].userDefaults setBool:[Common sharedManager].usePersonalizedAds forKey:UD_PERSONALIZED_ADS_KEY];
    [[Common sharedManager].userDefaults synchronize];
}

// ユーザー地域がEEAまたは不明であるか取得
- (BOOL)isRequestLocationInEEAOrUnknown
{
    return [PACConsentInformation sharedInstance].isRequestLocationInEEAOrUnknown;
}

@end
