//
//  RMTileSources.h
//  MapView
//
//  Created by Роман Беляковский on 3/26/12.
//  Copyright (c) 2012 djarvur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTileSource.h"

@interface RMTileSources : NSObject <RMTileSource> {
    NSMutableArray *tileSources;
}

@property (nonatomic, retain) NSMutableArray *tileSources;
@end
