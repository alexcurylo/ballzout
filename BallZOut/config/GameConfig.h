//
//  GameConfig.h
//  BallZOut
//
//  Created by alex on 10-09-24.
//  Copyright Trollwerks Inc. 2010. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
//#define GAME_AUTOROTATION kGameAutorotationUIViewController
#define GAME_AUTOROTATION kGameAutorotationNone


#endif // __GAME_CONFIG_H
