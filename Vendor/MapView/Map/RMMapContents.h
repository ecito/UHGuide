//
//  RMMapContents.h
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
#import <UIKit/UIKit.h>

#import "RMFoundation.h"
#import "RMLatLong.h"
#import "RMTile.h"

#import "RMTilesUpdateDelegate.h"


// constants for boundingMask
enum {
	// Map can be zoomed out past view limits
	RMMapNoMinBound			= 0,
	// Minimum map height when zooming out restricted to view height
	RMMapMinHeightBound		= 1,
	// Minimum map width when zooming out restricted to view width ( default )
	RMMapMinWidthBound		= 2
};

#define kDefaultInitialLatitude -33.858771;
#define kDefaultInitialLongitude 151.201596;

#define kDefaultMinimumZoomLevel 0.0
#define kDefaultMaximumZoomLevel 25.0
#define kDefaultInitialZoomLevel 13.0

@class RMMarkerManager;
@class RMProjection;
@class RMMercatorToScreenProjection;
@class RMTileImageSet;
@class RMTileLoader;
@class RMMapRenderer;
@class RMMapLayer;
@class RMLayerSet;
@class RMMarker;
@protocol RMMercatorToTileProjection;
@protocol RMTileSource;


@protocol RMMapContentsAnimationCallback <NSObject>
@optional
- (void)animationFinishedWithZoomFactor:(float)zoomFactor near:(CGPoint)p;
@end


/*! \brief The cartographic and data components of a map. Do not retain.
 
 There is exactly one RMMapContents instance for each RMMapView instance.
 
 \warning Do not retain an RMMapContents instance. Instead, ask the RMMapView for its contents 
 when you need it. It is an error for an RMMapContents instance to exist without a view, and 
 if you retain the RMMapContents, it can't go away when the RMMapView is released.
 
 At some point, it's likely that RMMapContents and RMMapView will be merged into one class.
 
 */
@interface RMMapContents : NSObject
{
	/// This is the underlying UIView's layer.
	CALayer *layer;
	
	RMMarkerManager *markerManager;
	/// subview for the image displayed while tiles are loading. Set its contents by providing your own "loading.png".
	RMMapLayer *background;
	/// subview for markers and paths
	RMLayerSet *overlay;
	
	/// (guess) the projection object to convert from latitude/longitude to meters.
	/// Latlong is calculated dynamically from mercatorBounds.
	RMProjection *projection;
	
	id<RMMercatorToTileProjection> mercatorToTileProjection;
//	RMTileRect tileBounds;
	
	/// (guess) converts from projected meters to screen pixel coordinates
	RMMercatorToScreenProjection *mercatorToScreenProjection;
	
	/// controls what images are used. Can be changed while the view is visible, but see http://code.google.com/p/route-me/issues/detail?id=12
	id<RMTileSource> tileSource;
	
	RMTileImageSet *imagesOnScreen;
	RMTileLoader *tileLoader;
	
	RMMapRenderer *renderer;
	NSUInteger		boundingMask;
	
	/// minimum zoom number allowed for the view. #minZoom and #maxZoom must be within the limits of #tileSource but can be stricter.
	float minZoom;
	/// maximum zoom number allowed for the view. #minZoom and #maxZoom must be within the limits of #tileSource but can be stricter.
	float maxZoom;

	id<RMTilesUpdateDelegate> tilesUpdateDelegate;
}

@property (readwrite) CLLocationCoordinate2D mapCenter;
@property (readwrite) RMXYRect XYBounds;
@property (readonly)  RMTileRect tileBounds;
@property (readonly)  CGRect screenBounds;
/*! \brief "scale" as of version 0.4/0.5 actually doesn't mean cartographic scale; it means meters per pixel.
 
 "Scale" is how many meters in 1 pixel. Larger scale means bigger things are smaller on the screen.
 "Scale" of 1 means 1 pixel == 1 meter.
 "Scale" of 10 means 1 pixel == 10 meters.
 \deprecated will be renamed metersPerPixel/setMetersPerPixel 
 */
@property (readwrite) float scale;
@property (readwrite) float zoom;

@property (readwrite) float minZoom, maxZoom;

@property (readonly)  RMTileImageSet *imagesOnScreen;
@property (readonly)  RMTileLoader *tileLoader;

@property (readonly)  RMProjection *projection;
@property (readonly)  id<RMMercatorToTileProjection> mercatorToTileProjection;
@property (readonly)  RMMercatorToScreenProjection *mercatorToScreenProjection;

@property (retain, readwrite) id<RMTileSource> tileSource;
@property (retain, readwrite) RMMapRenderer *renderer;

@property (readonly)  CALayer *layer;

@property (retain, readwrite) RMMapLayer *background;
@property (retain, readwrite) RMLayerSet *overlay;
@property (retain, readonly)  RMMarkerManager *markerManager;
/// \bug probably shouldn't be retaining this delegate
@property (nonatomic, retain) id<RMTilesUpdateDelegate> tilesUpdateDelegate;
@property (readwrite) NSUInteger boundingMask;
/// The denominator in a cartographic scale like 1/24000, 1/50000, 1/2000000.
/// \deprecated will be renamed scaleDenominator after 0.5
@property (readonly)double trueScaleDenominator;

- (id)initWithView: (UIView*) view;
- (id)initWithView: (UIView*) view
		tilesource:(id<RMTileSource>)newTilesource;
/// designated initializer
- (id)initWithView:(UIView*)view
		tilesource:(id<RMTileSource>)tilesource
	  centerLatLon:(CLLocationCoordinate2D)initialCenter
		 zoomLevel:(float)initialZoomLevel
	  maxZoomLevel:(float)maxZoomLevel
	  minZoomLevel:(float)minZoomLevel
   backgroundImage:(UIImage *)backgroundImage;

/// \deprecated subject to removal at any moment after 0.5 is released
- (id) initForView: (UIView*) view;
/// \deprecated subject to removal at any moment after 0.5 is released
- (id) initForView: (UIView*) view WithLocation:(CLLocationCoordinate2D)latlong;
/// \deprecated subject to removal at any moment after 0.5 is released
- (id)initForView:(UIView*)view WithTileSource:(id<RMTileSource>)tileSource WithRenderer:(RMMapRenderer*)renderer LookingAt:(CLLocationCoordinate2D)latlong;

- (void)setFrame:(CGRect)frame;

- (void)handleMemoryWarningNotification:(NSNotification *)notification;
- (void)didReceiveMemoryWarning;

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToXYPoint: (RMXYPoint)aPoint;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;
- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated;
- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated; 
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center animated:(BOOL) animated;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center animated:(BOOL) animated withCallback:(id<RMMapContentsAnimationCallback>)callback;

- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot;
- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot; 
- (float)adjustZoomForBoundingMask:(float)zoomFactor;
- (void)adjustMapPlacementWithScale:(float)aScale;
/// \deprecated removed after 0.5
- (void)setZoomBounds:(float)aMinZoom maxZoom:(float)aMaxZoom;
/// \deprecated renamed after 0.5
- (float)getNextNativeZoomFactor;

- (void) drawRect: (CGRect) rect;

//-(void)addLayer: (id<RMMapLayer>) layer above: (id<RMMapLayer>) other;
//-(void)addLayer: (id<RMMapLayer>) layer below: (id<RMMapLayer>) other;
//-(void)removeLayer: (id<RMMapLayer>) layer;

// During touch and move operations on the iphone its good practice to
// hold off on any particularly expensive operations so the user's 
+ (BOOL) performExpensiveOperations;
+ (void) setPerformExpensiveOperations: (BOOL)p;

- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong;
- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong withScale:(float)aScale;
- (RMTilePoint)latLongToTilePoint:(CLLocationCoordinate2D)latlong withScale:(float)aScale;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel withScale:(float)aScale;

- (void)zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)se;
- (void)zoomWithRMMercatorRectBounds:(RMXYRect)bounds;

/// \deprecated name change pending after 0.5
- (RMLatLongBounds) getScreenCoordinateBounds;
/// \deprecated name change pending after 0.5
- (RMLatLongBounds) getCoordinateBounds:(CGRect) rect;

- (void) tilesUpdatedRegion:(CGRect)region;

/*! \brief Clear all images from the #tileSource's caching system.
 
 All of the existing RMTileSource implementations load tile images via NSURLRequest. It's possible that some images will remain in your
 application's shared URL cache. If you need to clear this out too, use this call:
 \code
 [[NSURLCache sharedURLCache] removeAllCachedResponses];
 \endcode
 */
-(void)removeAllCachedImages;

@end

/// Appears to be the methods actually implemented by RMMapContents, but generally invoked on RMMapView, and forwarded to the contents object.
@protocol RMMapContentsFacade

@optional
- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToXYPoint: (RMXYPoint)aPoint;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;
- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated;
- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated; 
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center animated:(BOOL) animated;

- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot;
- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot; 
- (float)adjustZoomForBoundingMask:(float)zoomFactor;
- (void)adjustMapPlacementWithScale:(float)aScale;
- (void)setZoomBounds:(float)aMinZoom maxZoom:(float)aMaxZoom;

- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong;
- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong withScale:(float)aScale;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel withScale:(float)aScale;

- (void)zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)se;
- (void)zoomWithRMMercatorRectBounds:(RMXYRect)bounds;

/// \deprecated name change pending after 0.5
- (RMLatLongBounds) getScreenCoordinateBounds;
/// \deprecated name change pending after 0.5
- (RMLatLongBounds) getCoordinateBounds:(CGRect) rect;

- (void) tilesUpdatedRegion:(CGRect)region;

@end

