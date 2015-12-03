//
//  NSView+MMNavigatorFont.m
//  MMNavigatorFont
//
//  Created by Ralph Li on 12/3/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import "NSView+MMNavigatorFont.h"
#import <objc/runtime.h>

static const void *MMOriginalTitleFontKey    = &MMOriginalTitleFontKey;
static const void *MMOriginalSubtitleFontKey = &MMOriginalSubtitleFontKey;

@implementation NSView (MMNavigatorFont)
@dynamic originalTitleFont;
@dynamic originalSubtitleFont;


- (NSFont *)originalTitleFont {
    return objc_getAssociatedObject(self, MMOriginalTitleFontKey);
}

- (void)setOriginalTitleFont:(NSFont *)font {
    objc_setAssociatedObject(self, MMOriginalTitleFontKey, font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSFont *)originalSubtitleFont {
    return objc_getAssociatedObject(self, MMOriginalTitleFontKey);
}

- (void)setOriginalSubtitleFont:(NSFont *)font {
    objc_setAssociatedObject(self, MMOriginalSubtitleFontKey, font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
