//
//  SKShader.m
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "SKShader.h"
#import <OpenGLES/ES2/gl.h>

@interface SKShader () {
	BOOL linkingDone;
}

@property (strong, nonatomic) NSMutableArray *sources;

@end

@implementation SKShader

@synthesize sources;
@synthesize programId;

- (id)init {
	if ((self = [super init])) {
		self.sources = [NSMutableArray arrayWithCapacity:2];
		
		linkingDone = NO;
	}
	
	return self;
}

- (void)addSource:(NSString*)source ofType:(GLenum)type error:(NSError* __autoreleasing*)error {
	GLuint shaderId = glCreateShader(type);
	
	const char *byteSource = [source UTF8String];
	int length = [source length];
	glShaderSource(shaderId, 1, &byteSource, &length);
	
	glCompileShader(shaderId);
	
	GLint success;
	glGetShaderiv(shaderId, GL_COMPILE_STATUS, &success);
	
	if (success == GL_FALSE) {
		GLchar byteError[256];
		glGetShaderInfoLog(shaderId, sizeof(byteError), 0, byteError);
		NSString *errorString = [NSString stringWithUTF8String:byteError];
		NSDictionary *errorDetails = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"dk.gereen" code:1337 userInfo:errorDetails];
	}
	
	[self.sources addObject:[NSNumber numberWithUnsignedInt:shaderId]];
}

- (void)linkProgram:(NSError* __autoreleasing*)error {
	programId = glCreateProgram();
	
	for (NSNumber *shader in self.sources) {
		glAttachShader(programId, [shader unsignedIntValue]);
	}
	
	glLinkProgram(programId);
	
	GLint success;
	glGetProgramiv(programId, GL_LINK_STATUS, &success);
	
	if (success == GL_FALSE) {
		GLchar byteError[256];
		glGetProgramInfoLog(programId, sizeof(byteError), 0, byteError);
		NSString *errorString = [NSString stringWithCString:byteError encoding:NSUTF8StringEncoding];
		NSDictionary *errorDetails = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"dk.gereen" code:1337 userInfo:errorDetails];
	}
	
	glUseProgram(programId);
	
	linkingDone = YES;
}

- (GLuint)programId {
	if (!linkingDone) {
		[NSException raise:@"OpenGLException" format:@"Trying to access program ID before generated"];
	}
	
	return programId;
}

@end
