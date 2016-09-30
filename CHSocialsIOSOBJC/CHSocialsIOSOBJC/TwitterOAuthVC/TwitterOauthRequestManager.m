
#import "TwitterOauthRequestManager.h"
#import "SignatureParam.h"
#include "hmac.h"
#include "Base64Transcoder.h"
#import "Accounts/ACAccount.h"

#define TWITTER_KEY @"Mrxj2GTCHHyZmyL8c6LoZBThw"
#define TWITTER_SECRET @"7ku3jWOG7UbobXyJupVdgUEnprLivofJmbanmi8xOoUSSXbyMT"
#define TWITTER_REDIRECT_URL @"http://yulngu.com/callback"

@interface TwitterOauthRequestManager ()
@property (strong, nonatomic) NSString *mainURL;
@property (strong, nonatomic) NSString *nonce;
@property (strong, nonatomic) NSString *time;

@property (strong, nonatomic) NSString *authT;
@property (strong, nonatomic) NSString *authVerif;

@end

@implementation TwitterOauthRequestManager

- (instancetype)initWithURL:(NSString*)mainURL tocken:(NSString *)tocken verification:(NSString *)verif {
    if (self = [super init]) {
        self.authT = tocken;
        self.authVerif = verif;
        self.mainURL = mainURL;
    }
    return self;
}

- (void)startRequestWithSucces:(void(^)(NSString *))success
                       failure:(void(^)(NSError *))failure {
    [self initializationData];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.mainURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //! Twitter body parameyers
    [self setCurrentBodyFroRequest:request];
    //! Twitter autorization parameyers
    [self addOAuthAutorizationForRequest:request];

    NSURLSessionConfiguration *config =  [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sess = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [sess dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (success) {
            success(httpBody);
        }
    }];
    
    [task resume];
}

- (void)setCurrentBodyFroRequest:(NSMutableURLRequest *)request {
    
    //! Twitter body parameyers
    SignatureParam *bodyParameters = [[SignatureParam alloc] initWithN:@"oauth_verifier" v:self.authVerif];
    if (self.authVerif == nil) {
        bodyParameters = [[SignatureParam alloc] initWithN:@"oauth_callback" v:[self redirectURL]];
    }
    
    NSData *bodyData = [[NSString stringWithFormat:@"%@=%@", bodyParameters.neme, [self encodedURLParameterString:bodyParameters.value]] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:bodyData];
}

- (void)addOAuthAutorizationForRequest:(NSMutableURLRequest *)request {
    NSMutableArray *oauthHederParam = [NSMutableArray new];
    
    if (self.authT) {
        [oauthHederParam addObject:[NSString stringWithFormat:@"oauth_token=\"%@\"", self.authT]];
    }
    
    [oauthHederParam addObject:[NSString stringWithFormat:@"oauth_nonce=\"%@\"", self.nonce]];
    [oauthHederParam addObject:[NSString stringWithFormat:@"oauth_callback=\"%@\"", [self redirectURL]]];
    [oauthHederParam addObject:[NSString stringWithFormat:@"oauth_signature_method=\"%@\"", [self encodedURLParameterString:@"HMAC-SHA1"]]];
    [oauthHederParam addObject:[NSString stringWithFormat:@"oauth_timestamp=\"%@\"", self.time]];
    [oauthHederParam addObject:[NSString stringWithFormat:@"oauth_consumer_key=\"%@\"", [self encodedURLParameterString:TWITTER_KEY]]];
    [oauthHederParam addObject:[NSString stringWithFormat:@"oauth_signature=\"%@\"", [self signature]]];
    [oauthHederParam addObject:@"oauth_version=\"1.0\""];
    
    NSString *authStr = [oauthHederParam componentsJoinedByString:@", "];
    [request addValue:[NSString stringWithFormat:@"OAuth %@", authStr] forHTTPHeaderField:@"Authorization"];

}

- (NSString *)signature {
    NSMutableArray *parametersForOptimization = [NSMutableArray new];
    SignatureParam *p1 = [[SignatureParam alloc] initWithN:@"oauth_nonce" v:self.nonce];
    [parametersForOptimization addObject:p1];
    
    SignatureParam *p2 = [[SignatureParam alloc] initWithN:@"oauth_callback" v:[self redirectURL]];
    [parametersForOptimization addObject:p2];
    
    SignatureParam *p3 = [[SignatureParam alloc] initWithN:@"oauth_timestamp" v:self.time];
    [parametersForOptimization addObject:p3];
    
    SignatureParam *p4 = [[SignatureParam alloc] initWithN:@"oauth_consumer_key" v:TWITTER_KEY];
    [parametersForOptimization addObject:p4];
    
    SignatureParam *p5 = [[SignatureParam alloc] initWithN:@"oauth_signature_method" v:@"HMAC-SHA1"];
    [parametersForOptimization addObject:p5];
    
    SignatureParam *p6 = [[SignatureParam alloc] initWithN:@"oauth_version" v:@"1.0"];
    [parametersForOptimization addObject:p6];
    
    if (self.authT) {
        SignatureParam *p7 = [[SignatureParam alloc] initWithN:@"oauth_token=" v:self.authT];
        [parametersForOptimization addObject:p7];
    }
    
    //! signature optimization
    parametersForOptimization = [parametersForOptimization sortedArrayUsingComparator:^NSComparisonResult(SignatureParam *obj1, SignatureParam *obj2) {
        return [obj1.neme compare:obj2.neme options:NSCaseInsensitiveSearch];
    }].mutableCopy;
    
    NSMutableString *parametersStr = [NSMutableString new];
    for (int i = 0;i < parametersForOptimization.count;i++) {
        SignatureParam *p = parametersForOptimization[i];
        if (i == parametersForOptimization.count - 1) {
            [parametersStr appendFormat:@"%@=%@", p.neme, [self encodedURLParameterString:p.value]];
        } else {
            [parametersStr appendFormat:@"%@=%@&", p.neme, [self encodedURLParameterString:p.value]];
        }
    }
    
    //! add method, call_back
    NSString *temp2 = [NSString stringWithFormat:@"%@&%@&%@",
                       @"POST",
                       [self encodedURLParameterString:self.mainURL],
                       [self encodedURLString:parametersStr]];
    
    //! HMAC-SHA1 encodins
    //! preparing secret with &
    NSString *optimazedSecret = [TWITTER_SECRET stringByAppendingString:[NSString stringWithFormat:@"&%@", self.authT ? self.authT : @""]];
    NSData *secretData = [optimazedSecret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [temp2 dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    hmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char *)[secretData bytes], [secretData length], result);
    
    //! Base64 Encoding
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    NSString *emcodedSecret =[self encodedURLParameterString:base64EncodedResult];
    return emcodedSecret;
}


#pragma mark - Helper

- (NSString *)encodedURLString:(NSString *)str {
    
    NSString *str1 = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *str2 = [str1 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"?=&+"].invertedSet];
    return str2;
}

- (NSString *)encodedURLParameterString:(NSString *)str {
    //    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
    //                                                                                             (CFStringRef)str,
    //                                                                                             NULL,
    //                                                                                             CFSTR(":/=,!$&'()*+;[]@#?"),
    //                                                                                             kCFStringEncodingUTF8));
    
    NSString *str1 = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *str2 = [str1 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@":/=,!$&'()*+;[]@#?"].invertedSet];
    return str2;
}

- (void)initializationData {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSString *udNounce = (__bridge NSString *)(string);
    
    self.nonce = udNounce;
    self.time = @((int)[[NSDate date] timeIntervalSince1970]).stringValue;
}

- (NSString *)redirectURL{
    return [TWITTER_REDIRECT_URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
}
@end
