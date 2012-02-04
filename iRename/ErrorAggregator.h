//
//  ErrorAggregator.h
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@interface ErrorAggregator : NSObject {
    NSMutableArray *errors;
}

- (void)addError:(NSError *)error;
- (NSString *)getErrorStrings;
- (BOOL)hasErrors;
- (NSUInteger)numberOfErrors;
- (NSArray *)getErrors;

@end
