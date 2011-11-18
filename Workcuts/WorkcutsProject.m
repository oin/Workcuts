//
//  WorkcutsProject.m
//  Workcuts
//
//  Created by Jonathan Aceituno on 14/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

#import "WorkcutsProject.h"
#import "UKKQueue/UKKQueue.h"

@implementation WorkcutsProject

+(NSString*)configFileName
{
	return @"Workcuts.rb";
}

-(id)initWithPath:(NSString *)thePath
{
	self = [super init];
	if(self == nil || [thePath length] == 0)
		return nil;
	
	title_override = nil;
	
	// Try to open the project
	BOOL projectIsADirectory = NO;
	BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:thePath isDirectory:&projectIsADirectory];
	
	if(!pathExists || !projectIsADirectory) {
		[self release];
		return nil;
	}
	
	path = thePath;
	shortcuts = [[NSMutableArray alloc] init];
	
	[self watchConfigFile];
	
	return self;
}

-(void)dealloc
{
	NSNotificationCenter *wnc = [[NSWorkspace sharedWorkspace] notificationCenter];
	[wnc removeObserver:self];
	[[UKKQueue sharedFileWatcher] removePath:[self configFilePath]];
	[shortcuts release];
	[super dealloc];
}

-(void)watchConfigFile
{
	if([self configFileExists]) {
		[[UKKQueue sharedFileWatcher] addPath:[self configFilePath]];
		NSNotificationCenter *wnc = [[NSWorkspace sharedWorkspace] notificationCenter];
		[wnc addObserver:self selector:@selector(configFileDidChange:) name:UKFileWatcherWriteNotification object:nil];
	}
}

-(NSString*)path
{
	return path;
}

-(NSString*)title
{
	if(title_override)
		return title_override;
	return [path lastPathComponent];
}

-(NSString*)configFilePath
{
	return [[self path] stringByAppendingPathComponent:[WorkcutsProject configFileName]];
}

-(BOOL)configFileExists
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[self configFilePath]];
}

-(NSArray*)shortcuts
{
	return shortcuts;
}

-(WorkcutsShortcut*)shortcutWithIdentifier:(NSString*)identifier
{
	if([identifier length] == 0)
		return nil;
	
	// Check if the shortcut is already defined
	NSEnumerator *e = [shortcuts objectEnumerator];
	WorkcutsShortcut* value;
	
	while(value = [e nextObject]) {
		if([identifier isEqual:[value identifier]])
			return value;
	}
	
	// The object has not been found. Create it.
	value = [[WorkcutsShortcut alloc] initWithIdentifier:identifier];
	[shortcuts addObject:value];
	return value;
}

-(void)configFileDidChange:(id)notification
{
	// Reload the config file
	NSError *err = nil;
	NSString *contents = [NSString stringWithContentsOfFile:[self configFilePath] encoding:NSUTF8StringEncoding error:&err];
	if(err != nil) {
		[NSAlert alertWithError:err];
		return;
	}
	
	// Evaluate the contents
	Class ShortcutGrinder = NSClassFromString(@"ShortcutGrinder");
	[[[[ShortcutGrinder alloc] init] autorelease] evaluate:contents];
}

@end
