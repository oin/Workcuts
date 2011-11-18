//
//  WorkcutsShortcut.h
//  Workcuts
//
//  Created by Jonathan Aceituno on 18/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WorkcutsShortcut : NSObject {
	NSString* identifier;
	NSString* title;
	NSString* key;
	unsigned int keyModifiers;
	NSString* action;
}

-(id)initWithIdentifier:(NSString*)theIdentifier;
-(NSString*)identifier;
-(NSString*)title;
-(void)execute;

@end
