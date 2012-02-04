//
//  ErrorAggregator.m
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "ErrorAggregator.h"

@implementation ErrorAggregator

- (id)init
{
    self = [super init];
    if (self) {
        errors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addError:(NSError *)error
{
    [errors addObject:error];
}

- (NSString *)getErrorStrings
{
    NSMutableString *errorStr = [[NSMutableString alloc] init];
    for (NSError *err in errors) {
        [errorStr appendFormat:@"%@: %@", [err localizedFailureReason], [err localizedDescription]];
        [errorStr appendString:@"\n"];
    }
    errors = [[NSMutableArray alloc] init];
    return [errorStr mutableCopy];
}

- (BOOL)hasErrors
{
    return [errors count] > 0;
}

- (NSUInteger)numberOfErrors
{
    return [errors count];
}

- (NSArray *)getErrors
{
    NSArray *errs = [errors mutableCopy];
    errors = [[NSMutableArray alloc] init];
    return errs;
}

@end
