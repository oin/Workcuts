//
//  main.m
//  Workcuts
//
//  Created by Jonathan Aceituno on 14/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RubyCocoa/RubyCocoa.h>

int main(int argc, const char **argv)
{
	return [RubyCocoa applicationMainWithProgram:"app_init.rb" argc:argc argv:argv];
    //return NSApplicationMain(argc,  (const char **) argv);
}
