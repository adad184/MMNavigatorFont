//
//  NSObject_Extension.m
//  MMNavigatorFont
//
//  Created by Ralph Li on 12/3/15.
//  Copyright © 2015 LJC. All rights reserved.
//


#import "NSObject_Extension.h"
#import "MMNavigatorFont.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[MMNavigatorFont alloc] initWithBundle:plugin];
        });
    }
}
@end
