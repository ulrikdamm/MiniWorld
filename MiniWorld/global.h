//
//  Header.h
//  MiniWorld
//
//  Created by Ulrik Damm on 24/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#ifndef MiniWorld_Header_h
#define MiniWorld_Header_h

#import <AudioToolbox/AudioToolbox.h>

typedef enum {
	MWDirectionNone,
	MWDirectionLeft,
	MWDirectionRight,
	MWDirectionUp,
	MWDirectionDown,
} MWDirection;

extern SystemSoundID selectSound;

#endif
