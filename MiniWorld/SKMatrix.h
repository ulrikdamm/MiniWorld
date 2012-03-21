//
//  SKMatrix.h
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#ifndef spriteKit_SKMatrix_h
#define spriteKit_SKMatrix_h

#import <OpenGLES/ES2/gl.h>

typedef union {
	GLfloat values[16];
	
	struct {
		GLfloat m1;
		GLfloat m2;
		GLfloat m3;
		GLfloat m4;
		GLfloat m5;
		GLfloat m6;
		GLfloat m7;
		GLfloat m8;
		GLfloat m9;
		GLfloat m10;
		GLfloat m11;
		GLfloat m12;
		GLfloat m13;
		GLfloat m14;
		GLfloat m15;
		GLfloat m16;
	};
} SKMatrix;

inline SKMatrix SKMatrixZero(void);
inline SKMatrix SKMatrixWithValues(GLfloat *values);
inline SKMatrix SKMatricCopy(SKMatrix *matrix);

void SKMatrixOrtho(SKMatrix *matrix, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far);
void SKMatrixFrustum(SKMatrix *matrix, GLfloat left, GLfloat right, GLfloat top, GLfloat bottom, GLfloat near, GLfloat far);
void SKMatrixSwitchColumnsAndRows(SKMatrix *matrix);

void SKMatrixTranslate(SKMatrix *matrix, GLfloat x, GLfloat y, GLfloat z);
void SKMatrixRotate(SKMatrix *matrix, GLfloat x, GLfloat y, GLfloat z, GLfloat value);
void SKMatrixScale(SKMatrix *matrix, GLfloat x, GLfloat y, GLfloat z);

void SKMatrixMultiply(SKMatrix *matrix, SKMatrix *multiplierMatrix);

void SKMatrixPrint(SKMatrix *matrix);

#endif
