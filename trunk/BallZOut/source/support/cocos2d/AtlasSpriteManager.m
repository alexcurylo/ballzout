/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "AtlasSprite.h"
#import "AtlasSpriteManager.h"
#import "Grid.h"

const int defaultCapacity = 29;

#pragma mark AtlasSprite

@interface AtlasSprite (Remove)
-(void)setIndex:(int)idx;
@end

@implementation AtlasSprite (Remove)
-(void)setIndex:(int)idx
{
	atlasIndex_ = idx;
}
@end

@interface AtlasSpriteManager (private)
-(void) resizeAtlas;
@end

#pragma mark AtlasSpriteManager
@implementation AtlasSpriteManager

@synthesize atlas = textureAtlas_;

-(void)dealloc
{	
	[textureAtlas_ release];

	[super dealloc];
}

/*
 * creation with Texture2D
 */
+(id)spriteManagerWithTexture:(Texture2D *)tex
{
	return [[[AtlasSpriteManager alloc] initWithTexture:tex capacity:defaultCapacity] autorelease];
}

+(id)spriteManagerWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity
{
	return [[[AtlasSpriteManager alloc] initWithTexture:tex capacity:capacity] autorelease];
}

/*
 * creation with File Image
 */
+(id)spriteManagerWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity
{
	return [[[AtlasSpriteManager alloc] initWithFile:fileImage capacity:capacity] autorelease];
}

+(id)spriteManagerWithFile:(NSString*) imageFile
{
	return [[[AtlasSpriteManager alloc] initWithFile:imageFile capacity:defaultCapacity] autorelease];
}


/*
 * init with Texture2D
 */
-(id)initWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity
{
	if( (self=[super init])) {
		totalSprites_ = 0;
		textureAtlas_ = [[TextureAtlas alloc] initWithTexture:tex capacity:capacity];
		
		// no lazy alloc in this node
		children = [[NSMutableArray alloc] initWithCapacity:capacity];
	}

	return self;
}

/*
 * init with FileImage
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	if( (self=[super init]) ) {
		totalSprites_ = 0;
		textureAtlas_ = [[TextureAtlas alloc] initWithFile:fileImage capacity:capacity];
		
		// no lazy alloc in this node
		children = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	
	return self;
}


#pragma mark AtlasSpriteManager - composition

// override visit.
// Don't call visit on it's children
-(void) visit
{

	// CAREFUL:
	// This visit is almost identical to CocosNode#visit
	// with the exception that it doesn't call visit on it's children
	//
	// The alternative is to have a void AtlasSprite#visit, but this
	// although is less mantainable, is faster
	//
	if (!visible)
		return;
	
	glPushMatrix();
	
	if ( grid && grid.active)
		[grid beforeDraw];
	
	[self transform];
	
	[self draw];
	
	if ( grid && grid.active)
		[grid afterDraw:self.camera];
	
	glPopMatrix();
}

-(NSUInteger)indexForNewChildAtZ:(int)z
{
	NSUInteger idx = 0;

	for( AtlasSprite *sprite in children) {
		if ( sprite.zOrder > z ) {
			break;
		}
		idx++;
	}
		
	return idx;
}

-(AtlasSprite*) createSpriteWithRect:(CGRect)rect
{
	return [AtlasSprite spriteWithRect:rect spriteManager:self];
}

// override addChild:
-(id) addChild:(AtlasSprite*)child z:(int)z tag:(int) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[AtlasSprite class]], @"AtlasSpriteManager only supports AtlasSprites as children");
	
	if(totalSprites_ == textureAtlas_.capacity)
		[self resizeAtlas];

	NSUInteger idx = [self indexForNewChildAtZ:z];
	[child insertInAtlasAtIndex: idx];

	if( textureAtlas_.withColorArray )
		[child updateColor];

	totalSprites_++;
	[super addChild:child z:z tag:aTag];

	NSUInteger count = [children count];
	idx++;
	for(; idx < count; idx++) {
		AtlasSprite *sprite = (AtlasSprite *)[children objectAtIndex:idx];
		NSAssert([sprite atlasIndex] == idx - 1, @"AtlasSpriteManager: idx failed");
		[sprite setIndex:idx];		
	}
	
	return self;
}

// override removeChild:
-(void)removeChild: (AtlasSprite *)sprite cleanup:(BOOL)doCleanup
{
	// explicit nil handling
	if (sprite == nil)
		return;
	// ignore non-children 
	if( ![children containsObject:sprite] )
		return;
	
	NSUInteger idx= sprite.atlasIndex;
	[super removeChild:sprite cleanup:doCleanup];

	[textureAtlas_ removeQuadAtIndex:idx];

	// update all sprites beyond this one
	NSUInteger count = [children count];
	for(; idx < count; idx++)
	{
		AtlasSprite *other = (AtlasSprite *)[children objectAtIndex:idx];
		NSAssert([other atlasIndex] == idx + 1, @"AtlasSpriteManager: idx failed");
		[other setIndex:idx];
	}	
	totalSprites_--;
}

// override reorderChild
-(void) reorderChild:(AtlasSprite*)child z:(int)z
{
	// reorder child in the children array
	[super reorderChild:child z:z];

	
	// What's the new atlas idx ?
	NSUInteger newAtlasIndex = 0;
	for( AtlasSprite *sprite in children) {
		if( [sprite isEqual:child] )
			break;
		newAtlasIndex++;
	}
	
	if( newAtlasIndex != child.atlasIndex ) {

		[textureAtlas_ insertQuadFromIndex:child.atlasIndex atIndex:newAtlasIndex];
		
		// update atlas idx
		NSUInteger count = MAX( newAtlasIndex, child.atlasIndex);
		NSUInteger idx = MIN( newAtlasIndex, child.atlasIndex);
		for( ; idx < count+1 ; idx++ ) {
			AtlasSprite *sprite = (AtlasSprite *)[children objectAtIndex:idx];
			[sprite setIndex: idx];
		}
	}
}

-(void)removeChildAtIndex:(NSUInteger)idx cleanup:(BOOL)doCleanup
{
	[self removeChild:(AtlasSprite *)[children objectAtIndex:idx] cleanup:doCleanup];
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	[super removeAllChildrenWithCleanup:doCleanup];
	
	totalSprites_ = 0;
	[textureAtlas_ removeAllQuads];
}

#pragma mark AtlasSpriteManager - draw
-(void)draw
{
	for( AtlasSprite *child in children )
	{
		if( child.dirtyPosition )
			[child updatePosition];
		if( child.dirtyColor )
			[child updateColor];
	}

	if(totalSprites_ > 0)
	{
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		if( textureAtlas_.withColorArray )
			glEnableClientState(GL_COLOR_ARRAY);

		glEnable(GL_TEXTURE_2D);

		[textureAtlas_ drawQuads];

		glDisable(GL_TEXTURE_2D);

		if( textureAtlas_.withColorArray )
			glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
}

#pragma mark AtlasSpriteManager - private
-(void) resizeAtlas
{
	// if we're going beyond the current TextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	NSUInteger quantity = (textureAtlas_.totalQuads + 1) * 4 / 3;

	twlog("Resizing TextureAtlas capacity, from [%d] to [%d].", textureAtlas_.totalQuads, quantity);


	if( ! [textureAtlas_ resizeCapacity:quantity] ) {
		// serious problems
		twlog("WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: AltasSpriteManager#resizeAtlas SHALL handle this assert");
	}
	
	for(AtlasSprite *sprite in children)
		[sprite updateAtlas];
}
@end
