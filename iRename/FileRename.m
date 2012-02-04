//
//  FileRename.m
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "FileRename.h"

@interface FileRename ()
- (NSString *)getFileName:(NSString *)path;
- (NSString *)getDirectory:(NSString *)path;
@end

@implementation FileRename

@synthesize originalPath;
@synthesize renamedPath;
@synthesize originalPathFileName;
@synthesize renamedPathFileName;
@synthesize originalPathDirectory;
@synthesize renamedPathDirectory;

- (id)init
{
    return [self initWithFileName:@""];
}

- (id)initWithFileName:(NSString *)fn
{
    self = [super init];
    if (self) {
        self.originalPath = fn;
        self.renamedPath = fn;
    }
    return self;
}

#pragma mark Helper functions

- (NSString *)getFileName:(NSString *)path
{
    NSRange lps; // Last path separator
    lps = [path rangeOfString:@"/" options:NSBackwardsSearch];
    return [path substringFromIndex:(lps.location + 1)];
}

- (NSString *)getDirectory:(NSString *)path
{
    NSRange lps; // Last path separator
    lps = [path rangeOfString:@"/" options:NSBackwardsSearch];
    return [path substringToIndex:(lps.location)];
}

#pragma mark Reimplemented getters/setters

- (void)setOriginalPath:(NSString *)op
{
    originalPath = op;
    originalPathFileName = [self getFileName:op];
    originalPathDirectory = [self getDirectory:op];
}

- (void)setRenamedPath:(NSString *)rp
{
    renamedPath = rp;
    renamedPathFileName = [self getFileName:rp];
    renamedPathDirectory = [self getDirectory:rp];
}

@end
