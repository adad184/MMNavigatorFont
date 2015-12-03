//
//  MMNavigatorFont.h
//  MMNavigatorFont
//
//  Created by Ralph Li on 12/3/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import <AppKit/AppKit.h>

@class MMNavigatorFont;

static MMNavigatorFont *sharedPlugin;

@interface MMNavigatorFont : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end