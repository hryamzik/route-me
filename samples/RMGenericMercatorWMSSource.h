//
//  RMGenericMercatorWMSSource.h
//  LayeredMap
//
//  Created by Роман Беляковский on 3/25/12.
//  Copyright (c) 2012 djarvur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMAbstractWebMapSource.h"
#import "RMTileCache.h"

typedef struct { 
    CGPoint ul; 
    CGPoint lr; 
} CGXYRect; 

@interface RMGenericMercatorWMSSource : RMAbstractWebMapSource <RMTileSource> {
    NSMutableDictionary *wmsParameters;
    NSString *urlTemplate;
    CGFloat initialResolution, originShift;
    NSString *uniqueTilecacheKey;
    BOOL noCache;
    NSString *shortName;
}

@property (nonatomic, retain) NSString *uniqueTilecacheKey;
@property (nonatomic) BOOL noCache;
@property (nonatomic, retain) NSString *shortName;

- (RMGenericMercatorWMSSource *)initWithBaseUrl:(NSString *)baseUrl parameters:(NSDictionary *)params;

- (CGPoint)LatLonToMeters:(CLLocationCoordinate2D)latlon;
- (float)ResolutionAtZoom:(int)zoom;
- (CGPoint)PixelsToMeters:(int)px PixelY:(int)py atZoom:(int)zoom;
- (CLLocationCoordinate2D)MetersToLatLon:(CGPoint)meters;
- (CGXYRect)TileBounds:(RMTile)tile;

@end
