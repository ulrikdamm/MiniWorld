//
//  GLView.m
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "SKView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "SpriteKit.h"

@interface SKView () {
	GLuint colorRenderbuffer;
	GLuint framebuffer;
	
	GLuint shaderProjectionSlot;
}

- (void)setup;

@property (strong, nonatomic) CAEAGLLayer *glLayer;
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) NSMutableDictionary *sprites;
@property (strong, nonatomic) NSString *group;

@end

@implementation SKView

@synthesize glLayer;
@synthesize context;
@synthesize sprites;
@synthesize shader;
@synthesize group;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self setup];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setup];
	}
	
	return self;
}

- (void)setup {
	self.glLayer = (CAEAGLLayer*)self.layer;
	self.glLayer.opaque = YES;
	
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	if (!self.context || ![EAGLContext setCurrentContext:self.context]) {
		[NSException raise:@"OpenGLException" format:@"Couldn't set up context"];
	}
	
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	[self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.glLayer];
	
	glGenFramebuffers(1, &framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
	
	if (glGetError() != GL_NO_ERROR) {
		[NSException raise:@"OpenGLException" format:@"Error settings buffers"];
	}
	
	self.sprites = [NSMutableDictionary dictionary];
}

- (void)setShader:(SKShader *)newshader {
	shader = newshader;
	
	shaderProjectionSlot = glGetUniformLocation(shader.programId, "projection");
}

- (void)render {
	glClearColor(1, 1, 1, 1);
	glClear(GL_COLOR_BUFFER_BIT);
	
	SKMatrix matrix = SKMatrixZero();
	SKMatrixOrtho(&matrix, 0, self.frame.size.width, 0, self.frame.size.height, 0, 10);
	glUniformMatrix4fv(shaderProjectionSlot, 1, 0, matrix.values);
	
	glViewport(0, 0, self.frame.size.width, self.frame.size.height);
	
	for (SKSprite *sprite in [self.sprites objectForKey:group]) {
		[sprite draw];
	}
	
	[self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)addSprite:(SKSprite*)sprite {
	[[self.sprites objectForKey:group] addObject:sprite];
	
	[[self.sprites objectForKey:group] sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		if ([obj1 zpos] > [obj2 zpos]) {
			return (NSComparisonResult)NSOrderedDescending;
		}
		
		if ([obj1 zpos] < [obj2 zpos]) {
			return (NSComparisonResult)NSOrderedAscending;
		}
		return (NSComparisonResult)NSOrderedSame;
	}];
}

- (void)removeSprite:(SKSprite*)sprite {
	[[self.sprites objectForKey:group] removeObject:sprite];
}

- (BOOL)containsSprite:(SKSprite*)sprite {
	return [[self.sprites objectForKey:group] containsObject:sprite];
}

- (int)spriteCount {
	return [[self.sprites objectForKey:group] count];
}

- (void)setSpriteGroup:(NSString*)newgroup {
	self.group = newgroup;
	
	if ([self.sprites objectForKey:group] == nil) {
		[self.sprites setObject:[NSMutableArray array] forKey:group];
	}
}

- (BOOL)hasSpriteGroup:(NSString*)newgroup {
	return [self.sprites valueForKey:newgroup] != nil;
}

- (NSString*)currentSpriteGroup {
	return group;
}

+ (Class)layerClass {
	return [CAEAGLLayer class];
}

@end
