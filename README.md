# GDPRに対応した同意フォームを表示するサンプル（iOS）

AdMobを使用した iOSアプリで GDPRに対応した同意フォームを表示するサンプルです。

主に[公式ドキュメント](https://developers.google.com/admob/ios/eu-consent "公式ドキュメント")の情報を参考にしています。

## 導入準備

### 1. 広告技術プロバイダの選択

AdMobの管理画面にログインし、「ブロックの管理」→「EU ユーザーの同意」画面を開きます。

次に『広告技術プロバイダの選択』から『広告技術プロバイダのカスタム グループ』を選択します（この設定の反映には、自分の場合は1時間ほど要しました。反映されるまで同意フォームの読み込みエラーが発生しますので、気長に待ちましょう）。

また、『同意取得の設定』にある『サイト運営者 ID』も後に使用するので控えておきます。

### 2. CocoaPodsから SDKをインストール

_Podfile_ に「_pod 'PersonalizedAdConsent'_」の一行を追加し、SDKをインストールします。

## 実装

### 同意フォームの表示

EU圏内であれば同意フォームを表示し、従来通りのパーソナライズされた広告を表示するか、非パーソナライズされた広告を表示するかの設定を保持し、その設定によって広告のリクエストを分岐します。

#### ViewController.h

```objective-c
#import <UIKit/UIKit.h>
#import <PersonalizedAdConsent/PersonalizedAdConsent.h>
#import "Common.h"

@interface ViewController : UIViewController

@end
```

#### ViewController.m

```objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSString *const ADMOB_PUB_ID       = @"Your AdMob Publisher ID"; // AdMobのパブリッシャーID
NSString *const PRIVACY_POLICY_URL = @"Your Privacy Policy URL"; // プライバシーポリシーURL
BOOL      const PAC_DEBUG_MODE     = YES; // デバッグモード

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
             NSLog(@"Error -> requestConsentInfoUpdate: %@", error);
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
```

### 広告のパーソナライズ設定の保持

広告のパーソナライズ設定をユーザーデフォルトに保持します。

#### Common.h

```objective-c
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
```

#### Common.m

```objective-c
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
```

### 非パーソナライズ広告のリクエスト

非パーソナライズ広告を表示する場合は、下記のように広告のリクエスト時にパラメータを渡します。

```objective-c
GADRequest *request = [GADRequest request];
if (![Common sharedManager].usePersonalizedAds) {
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"npa": @"1"};
    [request registerAdNetworkExtras:extras];
}
```

以上が導入から実装までの大まかな流れになります。

EU圏内からのアプリ使用で、同意フォームを表示する場合はまだ広告を表示しないようにし、選択された内容によって従来通りのパーソナライズされた広告か、非パーソナライズされた広告を読み込むのが良いと思います。

また、アプリのどこかに同意フォームを再表示できるメニューやボタンを用意し、ユーザーがいつでも設定を変更できる必要があります。

大雑把な情報ではありますが、少しでもお役に立てば幸いです。
