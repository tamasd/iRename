//
//  FileRename.h
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@interface FileRename : NSObject {
    NSString *originalPath;
    NSString *renamedPath;
    
    NSString *originalPathFileName;
    NSString *renamedPathFileName;
    NSString *originalPathDirectory;
    NSString *renamedPathDirectory;
}

@property (nonatomic, copy) NSString *originalPath;
@property (nonatomic, copy) NSString *renamedPath;
@property (nonatomic, readonly, copy) NSString *originalPathFileName;
@property (nonatomic, readonly, copy) NSString *renamedPathFileName;
@property (nonatomic, readonly, copy) NSString *originalPathDirectory;
@property (nonatomic, readonly, copy) NSString *renamedPathDirectory;

- (id)initWithFileName:(NSString *)fn;

@end
