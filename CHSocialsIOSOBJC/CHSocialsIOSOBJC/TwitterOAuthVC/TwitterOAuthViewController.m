
#import "TwitterOAuthViewController.h"
#import "SignatureParam.h"
#include "hmac.h"
#include "Base64Transcoder.h"
#import "Accounts/ACAccount.h"
#import "TwitterOauthRequestManager.h"

#define TWITTER_REQUEST_TOKEN_URL @"https://api.twitter.com/oauth/request_token"
#define TWITTER_AUTHORIZE_URL @"https://api.twitter.com/oauth/authorize"
#define TWITTER_ACCESS_TOKEN_URL @"https://api.twitter.com/oauth/access_token"

#define TWITTER_KEY @"Mrxj2GTCHHyZmyL8c6LoZBThw"
#define TWITTER_SECRET @"7ku3jWOG7UbobXyJupVdgUEnprLivofJmbanmi8xOoUSSXbyMT"
#define TWITTER_REDIRECT_URL @"http://yulngu.com/callback"

@interface TwitterOAuthViewController () <UIWebViewDelegate>

@property (strong, nonatomic) NSString *nonce;
@property (strong, nonatomic) NSString *time;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *authT;
@property (strong, nonatomic) NSString *authVerif;
@end

@implementation TwitterOAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    TwitterOauthRequestManager *manager = [[TwitterOauthRequestManager alloc] initWithURL:TWITTER_REQUEST_TOKEN_URL tocken:nil verification:nil];
    __weak typeof (self) wSelf = self;
    [manager startRequestWithSucces:^(NSString *httpBody) {
        NSArray *components = [httpBody componentsSeparatedByString:@"&"];

        NSString *oauthToken = nil;
        NSString *oauthTokenSecret = nil;

        for (NSString *values in components) {
            if ([values rangeOfString:@"oauth_token="].length) {
                oauthToken = [values stringByReplacingOccurrencesOfString:@"oauth_token=" withString:@""];
            }
            if ([values rangeOfString:@"oauth_token_secret="].length) {
                oauthTokenSecret = [values stringByReplacingOccurrencesOfString:@"oauth_token_secret=" withString:@""];
            }
        }

        NSString *address = [NSString stringWithFormat:
                             @"https://api.twitter.com/oauth/authorize?oauth_token=%@",
                             oauthToken];

        NSURL *url = [NSURL URLWithString:address];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [wSelf.webView loadRequest:request];
    } failure:^(NSError *error) {
        //!
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -  UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType  {
    //! cancel action
    if ([request.URL.absoluteString rangeOfString:TWITTER_AUTHORIZE_URL].length > 0 && [request.URL.absoluteString rangeOfString:@"oauth_token="].length == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    if ([request.URL.absoluteString rangeOfString:TWITTER_REDIRECT_URL].length > 0) {
        NSArray *arurlParts = [request.URL.absoluteString componentsSeparatedByString:@"?"];
        NSArray *pairs = [arurlParts[1] componentsSeparatedByString:@"&"];
        
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token"]) {
                self.authT = [elements objectAtIndex:1];
            } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_secret"]) {
            } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_session_handle"]) {
            } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_duration"]) {
            } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_verifier"]) {
                self.authVerif = [elements objectAtIndex:1];
            } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_attributes"]) {
            } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_renewable"]) {
            }
        }
        TwitterOauthRequestManager *manager = [[TwitterOauthRequestManager alloc] initWithURL:TWITTER_ACCESS_TOKEN_URL tocken:self.authT verification:self.authVerif];
        //__weak typeof (self) wSelf = self;
        [manager startRequestWithSucces:^(NSString *httpBody) {
            
        } failure:^(NSError *error) {
            //!
        }];
        
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    if (error) {
        
    }
}

@end
