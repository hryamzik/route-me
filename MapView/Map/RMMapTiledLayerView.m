//
//  RMMapTiledLayerView.m
//  MapView
//
//  Created by Thomas Rasch on 17.08.11.
//  Copyright (c) 2011 Alpstein. All rights reserved.
//

#import "RMMapTiledLayerView.h"

#import "RMMapView.h"
#import "RMTileSource.h"

@interface RMMapOverlayView ()

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer;
- (void)handleTwoFingerDoubleTap:(UIGestureRecognizer *)recognizer;

@end

@implementation RMMapTiledLayerView

@synthesize delegate;

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (CATiledLayer *)tiledLayer
{  
    return (CATiledLayer *)self.layer;
}

- (id)initWithFrame:(CGRect)frame mapView:(RMMapView *)aMapView
{
    if (!(self = [super initWithFrame:frame]))
        return nil;

    mapView = [aMapView retain];

    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.opaque = NO;

    CATiledLayer *tiledLayer = [self tiledLayer];
    tiledLayer.levelsOfDetail = [[mapView tileSources] maxZoom];
    tiledLayer.levelsOfDetailBias = [[mapView tileSources] maxZoom];

    UITapGestureRecognizer *doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)] autorelease];
    doubleTapRecognizer.numberOfTapsRequired = 2;

    UITapGestureRecognizer *singleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];

    UITapGestureRecognizer *twoFingerDoubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerDoubleTap:)] autorelease];
    twoFingerDoubleTapRecognizer.numberOfTapsRequired = 2;
    twoFingerDoubleTapRecognizer.numberOfTouchesRequired = 2;

    UITapGestureRecognizer *twoFingerSingleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerSingleTap:)] autorelease];
    twoFingerSingleTapRecognizer.numberOfTouchesRequired = 2;
    [twoFingerSingleTapRecognizer requireGestureRecognizerToFail:twoFingerDoubleTapRecognizer];

    UILongPressGestureRecognizer *longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];

    [self addGestureRecognizer:singleTapRecognizer];
    [self addGestureRecognizer:doubleTapRecognizer];
    [self addGestureRecognizer:twoFingerDoubleTapRecognizer];
    [self addGestureRecognizer:twoFingerSingleTapRecognizer];
    [self addGestureRecognizer:longPressRecognizer];

    return self;
}

- (void)dealloc
{
    [[mapView tileSources] cancelAllDownloads];
    [mapView release]; mapView = nil;
    [super dealloc];
}

- (void)layoutSubviews
{
    self.contentScaleFactor = 1.0f;
//    NSLog(@"layerView layoutSubviews");
}

-(void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
//    CGRect frame = bounds;
//    NSLog(@"drawRect, bounds: %.2f %.2f %.2f %.2f",frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
//    NSLog(@"drawRect, rect:   %.4f %.4f %.4f %.4f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
//    NSLog(@"layerView contentScaleFactor = %f", [self contentScaleFactor]);
//    NSLog(@"layerSuperView contentScaleFactor = %f", [[self superview] contentScaleFactor]);

//    NSLog(@"drawRect: {{%f,%f},{%f,%f}}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    short zoom = log2(bounds.size.width / rect.size.width);
    int x = floor(rect.origin.x / rect.size.width), y = floor(fabs(rect.origin.y / rect.size.height));
//    NSLog(@"Tile @ x:%d, y:%d, zoom:%d", x, y, zoom);
//    NSLog(@"RMMapTiledLayerViewDelegate zoom = %d", zoom);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    

    
    int index = [self.superview.subviews indexOfObject:self];
    id <RMTileSource> tileSource = [mapView.tileSources.tileSources objectAtIndex:index];
    UIImage *tileImage = [tileSource imageForTile:RMTileMake(x, y, zoom) inCache:[mapView tileCache]];
//    NSLog(@"View num %d drawing image for tile %@", index, [tileSource uniqueTilecacheKey]);
    [tileImage drawInRect:rect];
////    int i = 0;
//    for (id <RMTileSource> ts in mapView.tileSources.tileSources) {
//        UIImage *tileImage = [ts imageForTile:RMTileMake(x, y, zoom) inCache:[mapView tileCache]];
//        [tileImage drawInRect:rect];
//        NSLog(@"View num %d drawing image for tile %@", [self.superview.subviews indexOfObject:self], [ts uniqueTilecacheKey]);
////        //debug
////        NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:
////                              [NSString stringWithFormat:@"Documents/tile[%d]x[%d]y[%d]z[%d].png",
////                               i, x,y,zoom]];
////        [UIImagePNGRepresentation(tileImage) writeToFile:pngPath atomically:YES];
////        NSError *error;
////        NSFileManager *fileMgr = [NSFileManager defaultManager];
////        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
////        NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
//    }

    [pool release]; pool = nil;
}

#pragma mark -
#pragma mark Event handling

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer
{
    if ([delegate respondsToSelector:@selector(mapTiledLayerView:singleTapAtPoint:)])
        [delegate mapTiledLayerView:self singleTapAtPoint:[recognizer locationInView:mapView]];
}

- (void)handleTwoFingerSingleTap:(UIGestureRecognizer *)recognizer
{
    if ([delegate respondsToSelector:@selector(mapTiledLayerView:twoFingerSingleTapAtPoint:)])
        [delegate mapTiledLayerView:self twoFingerSingleTapAtPoint:[recognizer locationInView:mapView]];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;

    if ([delegate respondsToSelector:@selector(mapTiledLayerView:longPressAtPoint:)])
        [delegate mapTiledLayerView:self longPressAtPoint:[recognizer locationInView:mapView]];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    if ([delegate respondsToSelector:@selector(mapTiledLayerView:doubleTapAtPoint:)])
        [delegate mapTiledLayerView:self doubleTapAtPoint:[recognizer locationInView:mapView]];
}

- (void)handleTwoFingerDoubleTap:(UIGestureRecognizer *)recognizer
{
    if ([delegate respondsToSelector:@selector(mapTiledLayerView:twoFingerDoubleTapAtPoint:)])
        [delegate mapTiledLayerView:self twoFingerDoubleTapAtPoint:[recognizer locationInView:mapView]];
}

@end
