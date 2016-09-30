//
//  TwitterOauthRequestManager.h
//  LINTest
//
//  Created by User on 30.09.16.
//  Copyright © 2016 User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterOauthRequestManager : NSObject
- (instancetype)initWithURL:(NSString *)mainURL tocken:(NSString *)tocken verification:(NSString *)verif;
- (void)startRequestWithSucces:(void(^)(NSString *))success
                       failure:(void(^)(NSError *))failure;
@end
