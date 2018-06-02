//
//  ViewController.m
//  PersonalizedAdConsentSample
//
//  Created by Dolice on 2018/06/03.
//  Copyright © 2018 Dolice. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSString *const ADMOB_PUB_ID       = @"Your AdMob Publisher ID";
NSString *const PRIVACY_POLICY_URL = @"Your Privacy Policy URL";
BOOL      const PAC_DEBUG_MODE     = YES;

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 広告のパーソナライズ設定
    [self initPersonalizedAdsSetting];
}

#pragma mark - Personalized Ads

// 広告のパーソナライズ設定
- (void)initPersonalizedAdsSetting
{
    // デバッグ用
    if (PAC_DEBUG_MODE) {
        // 実機の識別子をコンソール表示
        NSLog(@"Advertising ID: %@", ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString);
        
        // 上記で出力した実機の識別子を入力（シミュレータで確認する場合は不要）
        PACConsentInformation.sharedInstance.debugIdentifiers = @[@"Advertising ID"];
        
        // ユーザー地域をEU圏内に指定
        PACConsentInformation.sharedInstance.debugGeography = PACDebugGeographyEEA;
        
        // ユーザー地域をEU圏外に指定
        //PACConsentInformation.sharedInstance.debugGeography = PACDebugGeographyNotEEA;
    }
    
    // 広告のパーソナライズ設定初期化
    [[Common sharedManager] initPersonalizedAdsSetting];
    
    // ユーザー情報をリクエスト
    [PACConsentInformation.sharedInstance
     requestConsentInfoUpdateForPublisherIdentifiers:@[ADMOB_PUB_ID]
     completionHandler:^(NSError *_Nullable error) {
         if (error) {
             // エラー
             NSLog(@"Error -> requestConsentInfoUpdate: %@", error)
         } else {
             if ([PACConsentInformation sharedInstance].isRequestLocationInEEAOrUnknown) {
                 // EU圏内もしくは不明であればステータスをチェックする
                 NSUInteger const status = PACConsentInformation.sharedInstance.consentStatus;
                 switch (status) {
                     case PACConsentStatusPersonalized:
                     case PACConsentStatusNonPersonalized:
                         // TODO: 既に同意フォームから設定を保存済みなので、保存済みのパーソナライズ設定の広告を表示
                         
                         
                         break;
                     case PACConsentStatusUnknown:
                     default:
                         // 同意情報をユーザーから取得する必要があるので同意フォームを表示する
                         [self showConsentForm];
                         
                         break;
                 }
             } else {
                 // TODO: EU圏外であれば従来通りパーソナライズされた広告を表示
                 
             }
         }
     }];
}

// 同意フォームの表示
- (void)showConsentForm
{
    // プライバシーポリシーURLを指定し同意フォーム初期化
    NSURL *privacyURL = [NSURL URLWithString:PRIVACY_POLICY_URL];
    PACConsentForm *form = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:privacyURL];
    
    // パーソナライズ広告の同意ボタンの有無
    form.shouldOfferPersonalizedAds = YES;
    
    // パーソナライズされていない広告の同意ボタンの有無
    form.shouldOfferNonPersonalizedAds = YES;
    
    // 有料アプリへの誘導ボタンの有無
    form.shouldOfferAdFree = NO;
    
    // 同意フォームの読み込み
    [form loadWithCompletionHandler:^(NSError *_Nullable error) {
        if (error) {
            // ロードエラー
            NSLog(@"Error -> loadWithCompletionHandler: %@", error);
        } else {
            // ロード成功
            [form presentFromViewController:self
                          dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
                              if (error) {
                                  // エラー
                                  NSLog(@"Error -> presentFromViewController: %@", error);
                              } else {
                                  // ユーザーが同意フォームのどれを選択したかによって処理を分岐
                                  //PACConsentStatus *status = PACConsentInformation.sharedInstance.consentStatus; // 左記では型指定の警告が発生
                                  NSUInteger const status = PACConsentInformation.sharedInstance.consentStatus;
                                  
                                  switch (status) {
                                      case PACConsentStatusPersonalized:
                                          // パーソナライズ広告を表示するよう設定
                                          [[Common sharedManager] setPersonalizedAdsSetting:YES];
                                          
                                          // TODO: 広告の読み込み
                                          
                                          
                                          break;
                                      case PACConsentStatusNonPersonalized:
                                          // パーソナライズされていない広告を表示するよう設定
                                          [[Common sharedManager] setPersonalizedAdsSetting:NO];
                                          
                                          // TODO: 広告の読み込み
                                          
                                          
                                          break;
                                      case PACConsentStatusUnknown:
                                      default:
                                          // 同意が得られなかった場合の処理（通常は何もしない）
                                          
                                          break;
                                  }
                              }
                          }];
        }
    }];
}

@end
