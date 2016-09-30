
#import "LinkedInOAuth2ViewController.h"

#define LINKEDIN_KEY @"77mu1k300bhztp"
#define LINKEDIN_SECRET @"JNK42Uu39lcFbpX8"
#define LINKEDIN_REDIRECT_URL @"https://test.com"

@interface LinkedInOAuth2ViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LinkedInOAuth2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startRequestForLincedIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)startRequestForLincedIn {
    
    NSString *time = @([[NSDate date] timeIntervalSince1970]).stringValue;
    NSString *redirect = [LINKEDIN_REDIRECT_URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    
    NSString *str = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&redirect_uri=%@&state=linkedin%@&scope=r_basicprofile", LINKEDIN_KEY, redirect, time];

    NSURL *url = [NSURL URLWithString:str];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.delegate = self;
}


- (void)requestForToken:(NSString *)code {
    
    NSString *redirect = [LINKEDIN_REDIRECT_URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSString *authTockenEndP = @"https://www.linkedin.com/uas/oauth2/accessToken";
    NSString *parameters = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@", code, redirect, LINKEDIN_KEY, LINKEDIN_SECRET];
    NSData *postParam = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:authTockenEndP]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postParam;
    [request addValue:@"application/x-www-form-urlencoded;" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *config =  [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sess = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [sess dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //!
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dictionary);
        if ([dictionary valueForKey:@"access_token"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dictionary valueForKey:@"access_token"] forKey:@"LIKToken"];
            [self getUserInfo];
        }
    }];
    
    [task resume];
}


- (void)getUserInfo {
    NSString *authTockenEndP = @"https://api.linkedin.com/v1/people/~?format=json";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:authTockenEndP]];
    request.HTTPMethod = @"GET";
    [request addValue:[@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"LIKToken"]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionConfiguration *config =  [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sess = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [sess dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //!
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dictionary);
        if ([dictionary valueForKey:@"access_token"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dictionary valueForKey:@"access_token"] forKey:@"LIKToken"];
        }
    }];
    
    [task resume];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType  {
    //LINKEDIN
    if ([request.URL.absoluteString rangeOfString:@"https://test.com"].length > 0) {
        if ([request.URL.absoluteString rangeOfString:@"access_denied"].length) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        NSArray *arurlParts = [request.URL.absoluteString componentsSeparatedByString:@"?"];
        NSString *code = [arurlParts[1] componentsSeparatedByString:@"="][1];
        [self requestForToken:code];
        
        return NO;
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
