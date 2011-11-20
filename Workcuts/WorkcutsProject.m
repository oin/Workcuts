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
	
	if([self configFileExists])
		[self evaluate];
	
	return self;
}

-(void)dealloc
{
	[[[[NSClassFromString(@"WorkcutsShortcutProvider") alloc] init] autorelease] clear];
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
	Class WorkcutsShortcutProvider = NSClassFromString(@"WorkcutsShortcutProvider");
	return [[[[WorkcutsShortcutProvider alloc] init] autorelease] shortcuts];
}

-(void)evaluate
{
	// Reload the config file
	NSError *err = nil;
	NSString *contents = [NSString stringWithContentsOfFile:[self configFilePath] encoding:NSUTF8StringEncoding error:&err];
	if(err != nil) {
		[NSAlert alertWithError:err];
		return;
	}
	// Evaluate the contents
	[[[[NSClassFromString(@"WorkcutsShortcutProvider") alloc] init] autorelease] evaluate:contents];
	
	// Should reload the shortcuts
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadShortcuts" object:self];
}

-(void)configFileDidChange:(id)notification
{
	[self performSelectorOnMainThread:@selector(evaluate) withObject:self waitUntilDone:NO];
}

@end
