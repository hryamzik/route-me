//
//  RMGenericMercatorWMSSource.m
//  MapTests
//
//  Created by Роман Беляковский on 3/20/12.
//  Copyright (c) 2012 djarvur. All rights reserved.
//

#import "RMGenericMercatorWMSSource.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;}; 
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/ M_PI;}; 

@implementation RMGenericMercatorWMSSource
@synthesize uniqueTilecacheKey;
@synthesize noCache;
@synthesize shortName;

-(id) initWithBaseUrl:(NSString *)baseUrl parameters:(NSDictionary *)params
{ 
    if (![super init]) 
        return nil; 
    initialResolution = 2 * M_PI * 6378137 / [self tileSideLength];
    // 156543.03392804062 for sideLength 256 pixels 
    originShift = 2 * M_PI * 6378137 / 2.0;
    // 20037508.342789244 
    
    // setup default parameters
    // use official EPSG:3857 by default, user can override to 900913 if needed.
    wmsParameters = [[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] 
                                                                  initWithObjects:@"EPSG:900913",@"image/png",@"GetMap",@"1.1.1",@"WMS",nil] 
                                                         forKeys:[[NSArray alloc] initWithObjects:@"SRS",@"FORMAT",@"REQUEST",@"VERSION",@"SERVICE",nil]];
    [wmsParameters addEntriesFromDictionary:params];
    
    // build WMS request URL template
    urlTemplate = [NSString stringWithString:baseUrl];
    NSEnumerator *e = [wmsParameters keyEnumerator];
    NSString *key;
    NSString *delimiter = @"";
    while (key = [e nextObject]) {
        urlTemplate = [urlTemplate stringByAppendingFormat:@"%@%@=%@",
                       delimiter,
                       [[key uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
                       [[wmsParameters objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        delimiter = @"&";
    }
    int sideLength =  [self tileSideLength];
    urlTemplate = [urlTemplate stringByAppendingFormat:@"&WIDTH=%d&HEIGHT=%d",sideLength,sideLength];
    noCache = NO;
    shortName = @"Generic WMS Source";

    return self;
}

-(NSString*) tileURL: (RMTile) tile 
{ 
    //RMLatLongBounds tileBounds = [self TileLatLonBounds:tile];
    // Get BBOX coordinates in meters
    CGXYRect tileBounds = [self TileBounds:tile];
    
    NSString *url = [urlTemplate stringByAppendingFormat:@"&BBOX=%f,%f,%f,%f",
                     tileBounds.ul.x,
                     tileBounds.lr.y,
                     tileBounds.lr.x,
                     tileBounds.ul.y];
//    NSLog(@"Tile %d,%d,%d yields %@",tile.zoom, tile.x, tile.y, url); 
//    NSLog(@"Updating %@,\nurl=%@", uniqueTilecacheKey, url);
    return url; 
}

- (NSURL *)URLForTile:(RMTile)tile
{
//    NSLog(@"\nNSURL=%@", [NSURL URLWithString:[self tileURL:tile]]);
    return [NSURL URLWithString:[self tileURL:tile]];
}

- (UIImage *)imageForTile:(RMTile)tile inCache:(RMTileCache *)tileCache {
    if (noCache) {
//        NSLog(@"cache disablefd for %@", uniqueTilecacheKey);
//        [tileCache removeTile:tile withCacheKey:[self uniqueTilecacheKey]];
        return [super imageForTile:tile inCache:nil];
    }
    return [super imageForTile:tile inCache:tileCache];
}
// implement in subclass?
-(NSString*) uniqueTilecacheKey
{
    if (!uniqueTilecacheKey) {
        uniqueTilecacheKey = @"AbstractMercatorWMSSource";
    }
    return uniqueTilecacheKey;
}

//-(NSString *)shortName
//{
//    return @"Generic WMS Source";
//}
-(NSString *)longDescription
{
    return @"Generic WMS Source";
}
-(NSString *)shortAttribution
{
    return @"Generic WMS Source";
}
-(NSString *)longAttribution
{
    return @"Generic WMS Source";
}

-(float) minZoom
{
    return 2.0f;
}
-(float) maxZoom
{
    return 18.0f;
}

// Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:3857 
-(CGPoint) LatLonToMeters: (CLLocationCoordinate2D) latlon 
{ 
    CGPoint meters; 
    meters.x = latlon.longitude * originShift / 180.0; 
    meters.y = (log( tan((90.0 + latlon.latitude) * M_PI / 360.0 )) / (M_PI / 180.0)) * originShift / 180.0; 
    return meters; 
}

//Converts XY point from Spherical Mercator EPSG:3857 to lat/lon in WGS84 Datum 
-(CLLocationCoordinate2D) MetersToLatLon: (CGPoint) meters 
{ 
    CLLocationCoordinate2D latlon; 
    latlon.longitude = (meters.x / originShift) * 180.0; 
    latlon.latitude = (meters.y / originShift) * 180.0; 
    //latlon.latitude = - 180 / M_PI * (2 * atan( exp( latlon.latitude * M_PI / 180.0)) - M_PI / 2.0); 
    latlon.latitude = 180 / M_PI * (2 * atan( exp( latlon.latitude * M_PI / 180.0)) - M_PI / 2.0); 
    return latlon; 
} 

// Converts pixel coordinates in given zoom level of pyramid to EPSG:3857 
-(CGPoint) PixelsToMeters: (int) px PixelY:(int)py atZoom:(int)zoom 
{ 
    float resolution = [self ResolutionAtZoom: zoom]; 
    CGPoint meters; 
    meters.x = px * resolution - originShift; 
    meters.y = py * resolution - originShift; 
    return meters; 
} 

//Returns bounds of the given tile in EPSG:3857 coordinates 
-(CGXYRect)  TileBounds: (RMTile) tile 
{
    int sideLength =  [self tileSideLength];
    
    int zoom = tile.zoom;
    long twoToZoom = pow(2,zoom);
    CGXYRect tileBounds; 
    tileBounds.ul = [self PixelsToMeters: (tile.x * sideLength) 
                                  PixelY: ((twoToZoom-tile.y) * sideLength) 
                                  atZoom: zoom ]; 
    tileBounds.lr = [self PixelsToMeters: ((tile.x+1) * sideLength) 
                                  PixelY: ((twoToZoom-tile.y-1) * sideLength) 
                                  atZoom: zoom];
    return tileBounds; 
} 

//Resolution (meters/pixel) for given zoom level (measured at Equator) 
-(float) ResolutionAtZoom : (int) zoom 
{ 
    return initialResolution / pow(2,zoom); 
} 

@end