//
//  RMTileSources.m
//  MapView
//
//  Created by Роман Беляковский on 3/26/12.
//  Copyright (c) 2012 djarvur. All rights reserved.
//

#import "RMTileSources.h"

@implementation RMTileSources
@synthesize tileSources;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        tileSources = [NSMutableArray new];
        //        tileCaches = [NSMutableArray new];
    }
    return self;
}

- (float)minZoom {
    float minZoom = 0;
    for (id <RMTileSource> ms in tileSources) {
        if ([ms respondsToSelector:@selector(minZoom)]) {
            float mz = [(id <RMTileSource>)ms minZoom];
            if (minZoom < mz) {
                minZoom = mz;
            }
        }
    }
    return minZoom;
}

- (float)maxZoom {
    float maxZoom = 100;
    for (id <RMTileSource> ms in tileSources) {
        if ([ms respondsToSelector:@selector(maxZoom)]) {
            float mz = [(id <RMTileSource> )ms maxZoom];
            if (maxZoom > mz) {
                maxZoom = mz;
            }
        }
    }
    return maxZoom;
}

- (void)cancelAllDownloads {
    for (id <RMTileSource> ms in tileSources) {
        [ms cancelAllDownloads];
    }
}

- (RMProjection *) projection {
    if ([tileSources count] > 0) {
        return [[tileSources objectAtIndex:0] projection];
    }
    return nil;
}

- (RMFractalTileProjection *)mercatorToTileProjection {
    if ([tileSources count] > 0) {
        return [[tileSources objectAtIndex:0] mercatorToTileProjection];
    }
    return nil;
}

- (RMSphericalTrapezium)latitudeLongitudeBoundingBox {
    return [[tileSources objectAtIndex:0] latitudeLongitudeBoundingBox];
}

- (void)didReceiveMemoryWarning {
    for (id <RMTileSource> ms in tileSources) {
        [ms didReceiveMemoryWarning];
    }
}

- (int)tileSideLength {
    int tsl = 0;
    for (id <RMTileSource> ms in tileSources) {
        if ([ms respondsToSelector:@selector(tileSideLength)]) {
            int mz = [(id <RMTileSource>)ms tileSideLength];
            if (tsl < mz) {
                tsl = mz;
            }
        }
    }
    return tsl;
}

//- (void)removeAllCachedImages {
//    for (RMTileCache *cach in tileCaches) {
//        [cach removeAllCachedImages];
//    }
//}

//- (UIImage *)imageForTile:(RMTile)tile inCache:(RMTileCache *)tileCache;
//- (void)cancelAllDownloads;
//
//- (RMFractalTileProjection *)mercatorToTileProjection;
//- (RMProjection *)projection;
//
//- (float)minZoom;
//- (void)setMinZoom:(NSUInteger)aMinZoom;
//
//- (float)maxZoom;
//- (void)setMaxZoom:(NSUInteger)aMaxZoom;
//
//- (int)tileSideLength;
//- (void)setTileSideLength:(NSUInteger)aTileSideLength;
//
//- (RMSphericalTrapezium)latitudeLongitudeBoundingBox;
//
//- (NSString *)uniqueTilecacheKey;
//
//- (NSString *)shortName;
//- (NSString *)longDescription;
//- (NSString *)shortAttribution;
//- (NSString *)longAttribution;


@end
