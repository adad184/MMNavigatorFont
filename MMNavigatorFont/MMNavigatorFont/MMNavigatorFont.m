//
//  XcodeCustomizeFont.m
//  XcodeCustomizeFont
//
//  Created by Ralph Li on 12/2/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import <objc/runtime.h>

#import "MMNavigatorFont.h"
#import "NSView+MMNavigatorFont.h"
#import "Aspects.h"


#define MMWeakify(o)        __weak   typeof(self) mmwo = o;
#define MMStrongify(o)      __strong typeof(self) o = mmwo;

static NSString *const MMProjectFontKey    = @"MMProjectFontKey";
static NSString *const MMProjectEnabledKey = @"MMProjectEnabledKey";

@interface MMNavigatorFont()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@property (nonatomic, strong) NSMenuItem *menuItemEnable;
@property (nonatomic, strong) NSMenuItem *menuItemChoose;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSFont *selectedFont;
@property (nonatomic, weak)   NSView *outlineView;

@end

@implementation MMNavigatorFont

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        self.selectedFont = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:MMProjectFontKey]];
        self.enabled = [[[NSUserDefaults standardUserDefaults] objectForKey:MMProjectEnabledKey] boolValue];
        
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    [self setupMenu];
    [self setupHook];
}

- (void)setupMenu
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        self.menuItemEnable = [[NSMenuItem alloc] initWithTitle:@"Enable"
                                                         action:@selector(actionEnable)
                                                  keyEquivalent:@""];
        self.menuItemEnable.target = self;
        self.menuItemEnable.enabled = YES;
        self.menuItemEnable.state = self.enabled?NSOnState:NSOffState;
        
        self.menuItemChoose = [[NSMenuItem alloc] initWithTitle:@"Choose Font"
                                                         action:@selector(actionChoose)
                                                  keyEquivalent:@""];
        self.menuItemChoose.target = self;
        
        NSMenu *allMenu = [[NSMenu alloc] initWithTitle:@"Navigator Font"];
        allMenu.autoenablesItems = YES;
        [allMenu addItem:self.menuItemEnable];
        [allMenu addItem:self.menuItemChoose];
        
        
        NSMenuItem *customizeMenu = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Navigator Font"]
                                                               action:nil
                                                        keyEquivalent:@""];
        customizeMenu.submenu = allMenu;
        customizeMenu.enabled = YES;
        
        [[menuItem submenu] addItem:customizeMenu];
        
    }
}

- (void)setupHook
{
    
    MMWeakify(self);
    void(^fontBlock)(id<AspectInfo> info) = ^(id<AspectInfo> info) {
        MMStrongify(self);
        
        NSView *view = info.instance;
        if ( !view.originalTitleFont )
        {
            NSTextField *titleTextFiled = [view valueForKey:@"_titleTextField"];
            NSTextField *subtitleTextFiled = [view valueForKey:@"_subtitleTextField"];
            
            view.originalTitleFont = titleTextFiled.font;
            view.originalSubtitleFont = subtitleTextFiled.font;
        }
        
        
        if ( self.enabled && self.selectedFont )
        {
            [self applyFont:view];
        }
        
    };
    
    [objc_getClass("DVTTableCellViewOneLine") aspect_hookSelector:@selector(awakeFromNib)
                                                      withOptions:AspectPositionAfter
                                                       usingBlock:fontBlock
                                                            error:nil];
    [objc_getClass("DVTTableCellViewMultiLine") aspect_hookSelector:@selector(awakeFromNib)
                                                        withOptions:AspectPositionAfter
                                                         usingBlock:fontBlock
                                                              error:nil];
    
    
    
    
    void(^controlBarBlock)(id<AspectInfo> info) = ^(id<AspectInfo> info) {
        MMStrongify(self);
        
        self.outlineView = info.instance;
    };
    
    [objc_getClass("IDENavigatorOutlineView") aspect_hookSelector:@selector(viewDidMoveToSuperview)
                                                      withOptions:AspectPositionAfter
                                                       usingBlock:controlBarBlock
                                                            error:nil];
}

- (void)actionEnable
{
    self.enabled = !self.enabled;
    NSLog(@"actionEnable %d",self.enabled);
    self.menuItemEnable.state = self.enabled?NSOnState:NSOffState;
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@(self.enabled) forKey:MMProjectEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self refreshFont];
}

- (void)actionChoose
{
    NSLog(@"actionChoose");
    
    [[NSFontManager sharedFontManager] setDelegate:self];
    [[NSFontManager sharedFontManager] setSelectedFont:self.selectedFont?:[NSFont systemFontOfSize:13] isMultiple:NO];
    [[NSFontManager sharedFontManager] setTarget:self];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:nil];
}

- (void)changeFont:(id)sender {
    
    self.selectedFont = [sender convertFont:self.selectedFont];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.selectedFont] forKey:MMProjectFontKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ( self.enabled )
    {
        [self refreshFont];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshFont
{
    if ( self.outlineView )
    {
        [self refreshFontInView:self.outlineView];
    }
}

- (void)refreshFontInView:(NSView*)view
{
    for ( NSView *v in view.subviews )
    {
        [self refreshFontInView:v];
    }
    
    if ( [view isKindOfClass:NSClassFromString(@"DVTTableCellViewOneLine")] )
    {
        [self applyFont:view];
    }
}

- (void)applyFont:(NSView*)view
{
    NSTextField *titleTextFiled = [view valueForKey:@"_titleTextField"];
    NSTextField *subtitleTextFiled = [view valueForKey:@"_subtitleTextField"];
    
    if ( !self.enabled )
    {
        titleTextFiled.font = view.originalTitleFont;
        subtitleTextFiled.font = view.originalSubtitleFont;
        return;
    }
    
    if ( self.selectedFont )
    {
        titleTextFiled.font = self.selectedFont;
        subtitleTextFiled.font = self.selectedFont;
    }
}

@end
