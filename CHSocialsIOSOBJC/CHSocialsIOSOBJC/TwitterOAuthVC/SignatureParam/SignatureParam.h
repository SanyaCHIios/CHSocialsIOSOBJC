//
//  SignatureParam.h
//  LINTest
//
//  Created by User on 28.09.16.
//  Copyright © 2016 User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignatureParam : NSObject

@property (strong, nonatomic) NSString *neme;
@property (strong, nonatomic) NSString *value;

- (instancetype)initWithN:(NSString *)n v:(NSString *)v;

@end
