//
//  SignatureParam.m
//  LINTest
//
//  Created by User on 28.09.16.
//  Copyright © 2016 User. All rights reserved.
//

#import "SignatureParam.h"

@implementation SignatureParam
- (instancetype)initWithN:(NSString *)n v:(NSString *)v {
    if (self = [super init]) {
        self.neme = n;
        self.value = v;
    }
    return self;
}

- (NSString *)description {
    return self.neme;
}
@end
