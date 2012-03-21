//
//  SKSprite.m
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "SKSprite.h"

static GLushort indicies[] = {
	0, 1, 2,
	2, 3, 0,
};

@interface SKSprite () {
	GLuint shaderModelViewSlot;
	GLuint shaderPositionSlot;
	GLuint shaderColorSlot;
	GLuint shaderTexCoordSlot;
	GLuint shaderTextureSlot;
	
	GLuint vertexBuffer;
	GLuint indexBuffer;
	
	SKVertex vertices[4];
}

- (void)updateBuffers;

@end

@implementation SKSprite

@synthesize texture;
@synthesize position;
@synthesize shader;
@synthesize size;
@synthesize textureClip;
@synthesize anchor;
@synthesize alpha;
@synthesize zpos;
@synthesize subsprites;
@synthesize visible;

- (id)initWithTexture:(SKTexture*)newtexture shader:(SKShader*)newshader {
	if ((self = [self init])) {
		self.texture = newtexture;
		self.shader = newshader;
		self.visible = YES;
	}
	
	return self;
}

- (id)init {
	if ((self = [super init])) {
		self.subsprites = [NSMutableArray array];
		
		SKVertex tmpVertices[] = {
			{{.5, -.5, 0}, {1, 1, 1, 1}, {1, 0}},
			{{.5, .5, 0}, {1, 1, 1, 1}, {1, 1}},
			{{-.5, .5, 0}, {1, 1, 1, 1}, {0, 1}},
			{{-.5, -.5, 0}, {1, 1, 1, 1}, {0, 0}},
		};
		
		memcpy(vertices, tmpVertices, sizeof(tmpVertices));
		
		[self updateBuffers];
	}
	
	return self;
}

- (void)setShader:(SKShader *)newshader {
	shader = newshader;
	
	shaderPositionSlot = glGetAttribLocation(self.shader.programId, "position");
	shaderColorSlot = glGetAttribLocation(self.shader.programId, "sourceColor");
	shaderModelViewSlot = glGetUniformLocation(self.shader.programId, "modelView");
	shaderTexCoordSlot = glGetAttribLocation(self.shader.programId, "texCoordIn");
	shaderTextureSlot = glGetUniformLocation(self.shader.programId, "texture");
	
	glEnableVertexAttribArray(shaderPositionSlot);
	glEnableVertexAttribArray(shaderColorSlot);
	glEnableVertexAttribArray(shaderTexCoordSlot);
}

- (void)setTextureClip:(CGRect)newTextureClip {
	textureClip = newTextureClip;
	
	GLfloat x1 = (textureClip.origin.x) / self.texture.size.width;
	GLfloat y1 = (textureClip.origin.y) / self.texture.size.height;
	GLfloat x2 = (textureClip.origin.x + textureClip.size.width) / self.texture.size.width;
	GLfloat y2 = (textureClip.origin.y + textureClip.size.height) / self.texture.size.height;
	
	SKVertex tmpVertices[] = {
		{{.5, -.5, 0}, {1, 1, 1, 1}, {x2, y1}},
		{{.5, .5, 0}, {1, 1, 1, 1}, {x2, y2}},
		{{-.5, .5, 0}, {1, 1, 1, 1}, {x1, y2}},
		{{-.5, -.5, 0}, {1, 1, 1, 1}, {x1, y1}},
	};
	
	memcpy(vertices, tmpVertices, sizeof(tmpVertices));
	
	[self updateBuffers];
}

- (void)updateBuffers {
	glDeleteBuffers(1, &vertexBuffer);
	glDeleteBuffers(1, &indexBuffer);
	
	GLuint buffers[2];
	glGenBuffers(2, buffers);
	
	vertexBuffer = buffers[0];
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	
	indexBuffer = buffers[1];
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indicies), indicies, GL_STATIC_DRAW);
}

- (void)draw {
	if (!visible) {
		return;
	}
	
	if (self.alpha) {
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_BLEND);
	}
	
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	
	SKMatrix modelMatrix = SKMatrixZero();
	SKMatrixTranslate(&modelMatrix, self.position.x, self.position.y, 0);
	SKMatrixTranslate(&modelMatrix, -self.anchor.x, -self.anchor.y, 0);
	SKMatrixScale(&modelMatrix, self.size.width, self.size.height, 0);
	glUniformMatrix4fv(shaderModelViewSlot, 1, 0, modelMatrix.values);
	
	glVertexAttribPointer(shaderPositionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SKVertex), 0);
	glVertexAttribPointer(shaderColorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(SKVertex), (GLvoid*)(sizeof(GLfloat) * 3));
	glVertexAttribPointer(shaderTexCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SKVertex), (GLvoid*)(sizeof(GLfloat) * 7));
	
	glActiveTexture(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, self.texture.textureId);
	glUniform1i(shaderTextureSlot, 0);
	
	glDrawElements(GL_TRIANGLES, sizeof(indicies) / sizeof(indicies[0]), GL_UNSIGNED_SHORT, 0);
	
	for (SKSprite *sprite in self.subsprites) {
		[sprite draw];
	}
}

- (void)dealloc {
	glDeleteBuffers(1, &vertexBuffer);
	glDeleteBuffers(1, &indexBuffer);
}

@end
