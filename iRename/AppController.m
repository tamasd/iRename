//
//  AppController.m
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "AppController.h"
#import "FileRename.h"
#import "RenameViewController.h"
#import "ErrorAggregator.h"

@interface AppController ()
- (void)addDirectoryRecursiveHelper:(NSURL *)dirURL addDirectories:(BOOL)dir;
- (FileRename *)urlToFileRenameObject:(NSURL *)url addDir:(BOOL)addDir;
- (void)startIndeterminateProgress;
- (void)startDeterminateProgress:(NSRange)r;
- (void)startProgress;
- (void)stopProgress;
- (void)removeFiles:(NSArray *)files;
- (void)addFiles:(NSArray *)files;
- (void)changeKeyPath:(NSString *)keyPath ofObject:(id)obj toValue:(id)newValue;
- (void)stopObserving:(NSArray *)files;
- (void)startObserving:(NSArray *)files;
@end

@implementation AppController

static void *iRenameKVOContext;

@synthesize transformationWindowOKButtonEnabled;

- (id)init
{
    self = [super init];
    if (self) {
        readQueue = [[NSOperationQueue alloc] init];
        [readQueue setMaxConcurrentOperationCount:1];
        
        renameQueue = [[NSOperationQueue alloc] init];
        [renameQueue setMaxConcurrentOperationCount:4]; // Be gentle with the hard disk
        
        waitQueue = [[NSOperationQueue alloc] init];
        [waitQueue setMaxConcurrentOperationCount:1];
        
        errors = [[ErrorAggregator alloc] init];
        
        [self setTransformationWindowOKButtonEnabled:YES];
    }
    return self;
}

- (void)awakeFromNib
{
    undo = [parentWindow undoManager];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Actions

- (IBAction)addDirectoryRecursive:(id)sender
{
    NSOpenPanel *dlg = [NSOpenPanel openPanel];
    __block __weak AppController *ac = self;
    [dlg setCanChooseFiles:YES];
    [dlg setCanChooseDirectories:YES];
    [dlg setAllowsMultipleSelection:YES];
    [dlg beginSheetModalForWindow:parentWindow completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            for (NSURL *selectedURL in [dlg URLs]) {
                [readQueue addOperationWithBlock:^{
                    [ac addDirectoryRecursiveHelper:selectedURL addDirectories:NO];
                }];
            }
        }
    }];
}

- (IBAction)clear:(id)sender
{
    NSRange r = NSMakeRange(0, [[arrayController arrangedObjects] count]);
#ifdef DEBUG
    NSLog(@"Removing data in range %lu-%lu", r.location, r.length);
#endif
#ifndef NO_UNDO
    NSArray *all = [[arrayController arrangedObjects] copy];
    [undo registerUndoWithTarget:self selector:@selector(addFiles:) object:all];
#endif
    [self stopObserving:[arrayController arrangedObjects]];
    NSIndexSet *idx = [NSIndexSet indexSetWithIndexesInRange:r];
    [arrayController removeObjectsAtArrangedObjectIndexes:idx];
}

- (IBAction)doRename:(id)sender
{
    [self cancelRename:sender];
    
    id files = nil;
    NSInteger listTag = [[fileListOption selectedCell] tag];
    switch (listTag) {
        case SELECTED_FILES_TAG:
            files = [arrayController selectedObjects];
            break;
            
        case ALL_FILES_TAG:
            files = [arrayController arrangedObjects];
            break;
    }
    
    NSInteger rangeTag = [[replaceRangeOption selectedCell] tag];
    
    NSError *replaceInitError;
    if(![rvc beginReplacing:&replaceInitError]) {
        [NSAlert alertWithError:replaceInitError];
    } else {
        for (FileRename *fr in files) {
            NSString *originalPath = [fr originalPath];
            NSString *renamedPath = originalPath;
            switch (rangeTag) {
                case FULL_PATH_TAG:
                    renamedPath = [rvc applyOnString:originalPath];
                    break;
                    
                case ONLY_IN_FILENAME_TAG:
                    {
                        NSString *fileName = [fr originalPathFileName];
                        
                        // Get the directory
                        NSUInteger split = [originalPath length] - [fileName length];
                        NSString *dir = [originalPath substringToIndex:split];
                        
                        renamedPath = [dir stringByAppendingString:[rvc applyOnString:fileName]];
                    }
                    break;
                    
                default:
                    break;
            }
            [fr setRenamedPath:renamedPath];
        }
    }
    
    [rvc endReplacing];
}

- (IBAction)cancelRename:(id)sender
{
    [transformationWindow orderOut:transformationWindow];
    [NSApp endSheet:transformationWindow];
}

- (IBAction)executeRename:(id)sender
{
    [self startIndeterminateProgress];
    
    __block NSFileManager *fm = [NSFileManager defaultManager];
    __unsafe_unretained __block NSWindow *pW = parentWindow;
    __weak __block ErrorAggregator *errs = errors;
    __weak __block NSOperationQueue *rQ = renameQueue;
    __weak __block AppController *ac = self;
    
#ifndef NO_UNDO
    [undo removeAllActions];
#endif

    for (__weak __block FileRename *fr in [arrayController arrangedObjects]) {
        NSString *originalPath = [fr originalPath];
        NSString *renamedPath = [fr renamedPath];
        if ([originalPath compare:renamedPath] != NSOrderedSame) {
            [renameQueue addOperationWithBlock:^{
                NSError *error;
                BOOL cont = YES;
                if ([[fr originalPathDirectory] compare:[fr renamedPathDirectory]] != NSOrderedSame) {
                    cont = cont && [fm createDirectoryAtPath:[fr renamedPathDirectory] withIntermediateDirectories:YES attributes:NULL error:&error];
                }
                if (cont && [fm moveItemAtPath:originalPath toPath:renamedPath error:&error]) {
                    // After renaming the file, the original filename should be
                    // updated.
                    // This is normally slow, but the renaming operation
                    // is much slower and this seems to be the easiest solution.
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [fr setOriginalPath:renamedPath];
                    }];
                } else {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [errs addError:error];
                    }];
                }
            }];
        }
    }
    [waitQueue addOperationWithBlock:^{
        [rQ waitUntilAllOperationsAreFinished];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [ac stopProgress];
            NSAlert *alert = nil;
            if ([errs hasErrors]) {
                if ([errs numberOfErrors] == 1) {
                    alert = [NSAlert alertWithError:[[errs getErrors] objectAtIndex:0]];
                } else {
                    alert = [NSAlert alertWithMessageText:@"Multiple errors occoured." 
                                    defaultButton:@"OK" 
                                  alternateButton:nil 
                                      otherButton:nil 
                        informativeTextWithFormat:[errs getErrorStrings]];
                }
            } else {
                // Create the string with the link
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Love this app? Click here to donate."];
                NSRange r = NSMakeRange(0, [str length]);
                [str beginEditing];
                [str addAttribute:NSLinkAttributeName 
                            value:[[NSURL alloc] 
                                   initWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KXEWMR85MKGF4"] 
                            range:r];
                [str addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:r];
                [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:r];
                [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]] range:r];
                [str endEditing];
                
                // Create the accessory view
                NSTextView *accessory = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 300, 15)];
                [accessory insertText:str];
                [accessory setEditable:NO];
                [accessory setDrawsBackground:NO];
                
                alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"Renaming finished"];
                [alert setAccessoryView:accessory];
                [alert setAlertStyle:NSInformationalAlertStyle];
            }
            
            [alert beginSheetModalForWindow:pW modalDelegate:nil didEndSelector:nil contextInfo:nil];
        }];
    }];
}

#pragma mark Helpers

- (void)displayRenameDialog:(RenameViewController *)_rvc
{
    // Try end editing
    NSWindow *w = [container window];
    if (![w makeFirstResponder:w]) {
        NSBeep();
        return;
    }
    
    [self setTransformationWindowOKButtonEnabled:YES];
    
    rvc = _rvc;
    
    // Put the view in the box
    NSView *v = [rvc view];
    
    NSSize currentSize = [[container contentView] frame].size;
    NSSize newSize = [v frame].size;
    
    float deltaWidth = newSize.width - currentSize.width;
    float deltaHeight = newSize.height - currentSize.height;
    NSRect windowFrame = [w frame];
    windowFrame.size.height += deltaHeight;
    windowFrame.origin.y -= deltaHeight; // (0,0) is in the bottom left corner!
    windowFrame.size.width += deltaWidth;
    
    // Clear the box for resizing
    [container setContentView:nil];
    [w setFrame:windowFrame display:YES animate:YES];
    
    [container setContentView:v];
    [v setNextResponder:_rvc];
    [rvc setNextResponder:container];
    
    [NSApp beginSheet:transformationWindow 
       modalForWindow:parentWindow 
        modalDelegate:nil 
       didEndSelector:NULL 
          contextInfo:NULL];
}

- (FileRename *)urlToFileRenameObject:(NSURL *)url addDir:(BOOL)addDir
{
    BOOL add = true;
    NSString *path = [url path];
    
    if (!addDir) {
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if (isDirectory) {
            add = false;
        }
    }
    
    if (add) {
        FileRename *fr = [[FileRename alloc] initWithFileName:path];
        [fr addObserver:self forKeyPath:@"renamedPath" options:NSKeyValueObservingOptionOld context:&iRenameKVOContext];
        return fr;
    }
    return nil;
}

- (void)addDirectoryRecursiveHelper:(NSURL *)dirURL addDirectories:(BOOL)dir
{
    NSFileManager *fm = [NSFileManager new];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtURL:dirURL 
                              includingPropertiesForKeys:nil 
                                                 options:NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                            errorHandler:nil];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self startIndeterminateProgress];
    }];
    
    NSMutableArray *toAdd = [[NSMutableArray alloc] init];
    
    FileRename *fr = [self urlToFileRenameObject:dirURL addDir:dir];
    if (fr != nil) {
        [toAdd addObject:fr];
    }
    
    for (NSURL *url in dirEnum) {
        fr = [self urlToFileRenameObject:url addDir:dir];
        if (fr != nil) {
            [toAdd addObject:fr];
        }
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addFiles:toAdd];
        [self stopProgress];
    }];
}

- (void)addFiles:(NSArray *)files
{
    [arrayController addObjects:files];
#ifndef NO_UNDO
    [undo registerUndoWithTarget:self selector:@selector(removeFiles:) object:files];
#endif
}

- (void)removeFiles:(NSArray *)files
{
    [arrayController removeObjects:files];
    [self stopObserving:files];
#ifndef NO_UNDO
    [undo registerUndoWithTarget:self selector:@selector(addFiles:) object:files];
#endif
}

- (void)startObserving:(NSArray *)files
{
    for (FileRename *fr in files) {
        [fr addObserver:self forKeyPath:@"renamedPath" options:NSKeyValueObservingOptionOld context:&iRenameKVOContext];
    }
}

- (void)stopObserving:(NSArray *)files
{
    for (FileRename *fr in files) {
        [fr removeObserver:self forKeyPath:@"renamedPath"];
    }
}

- (void)startIndeterminateProgress
{
    [progressIndicator setIndeterminate:YES];
    [progressIndicator startAnimation:nil];

    [self startProgress];
}

- (void)startDeterminateProgress:(NSRange)r
{
    [progressIndicator setIndeterminate:NO];
    [progressIndicator setMinValue:r.location];
    [progressIndicator setMaxValue:r.length];
    [progressIndicator setDoubleValue:r.location];

    [self startProgress];
}

- (void)startProgress
{
    [NSApp beginSheet:progressWindow 
       modalForWindow:parentWindow 
        modalDelegate:nil 
       didEndSelector:NULL 
          contextInfo:NULL];
    [[NSApp mainWindow] makeKeyAndOrderFront:progressWindow];
}

- (void)stopProgress
{
    if ([progressIndicator isIndeterminate]) {
        [progressIndicator stopAnimation:nil];
    }
    [progressWindow orderOut:progressWindow];
    [NSApp endSheet:progressWindow];
}

#pragma mark KVO Observing

- (void)changeKeyPath:(NSString *)keyPath ofObject:(id)obj toValue:(id)newValue
{
    [obj setValue:newValue forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &iRenameKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        
        if (oldValue == [NSNull null]) {
            oldValue = nil;
        }
        
        [[undo prepareWithInvocationTarget:self] changeKeyPath:keyPath ofObject:object toValue:oldValue];
    }
}

@end
