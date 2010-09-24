//
//  RMMarker.m
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

#import "RMMarker.h"
#import "RMMarkerStyle.h"
#import "RMMarkerStyles.h"

#import "RMPixel.h"

NSString* const RMMarkerBlueKey = @"RMMarkerBlueKey";
NSString* const RMMarkerRedKey = @"RMMarkerRedKey";

static CGImageRef _markerRed = nil;
static CGImageRef _markerBlue = nil;

@implementation RMMarker

@synthesize location;
@synthesize data;
@synthesize labelView;
@synthesize textForegroundColor;
@synthesize textBackgroundColor;

+ (RMMarker*) markerWithNamedStyle: (NSString*) styleName
{
	WarnDeprecated();
	return [[[RMMarker alloc] initWithNamedStyle: styleName] autorelease];
}

// init
- (id)init
{
    if (self = [super init]) {
        labelView = nil;
        textForegroundColor = [UIColor blackColor];
        textBackgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id) initWithCGImage: (CGImageRef) image
{
	WarnDeprecated();
	return [self initWithCGImage: image anchorPoint: CGPointMake(0.5, 1.0)];
}

- (id) initWithCGImage: (CGImageRef) image anchorPoint: (CGPoint) _anchorPoint
{
	WarnDeprecated();
	if (![self init])
		return nil;
	
	self.contents = (id)image;
	self.bounds = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
	self.anchorPoint = _anchorPoint;
	
	self.masksToBounds = NO;
	self.labelView = nil;
	
	return self;
}

- (void) replaceImage:(CGImageRef)image anchorPoint:(CGPoint)_anchorPoint
{
	WarnDeprecated();
	self.contents = (id)image;
	self.bounds = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
	self.anchorPoint = _anchorPoint;
	
	self.masksToBounds = NO;
}

- (void) replaceKey: (NSString*) key
{
	WarnDeprecated();
	[self replaceImage:[RMMarker markerImage:key] anchorPoint: CGPointMake(0.5, 1.0)];
}

- (id) initWithUIImage: (UIImage*) image
{
	if (![self init])
		return nil;
	
	self.contents = (id)[image CGImage];
	self.bounds = CGRectMake(0,0,image.size.width,image.size.height);
	
	self.masksToBounds = NO;
	self.labelView = nil;
	
	return self;
}

- (void) replaceUIImage: (UIImage*) image
{
	self.contents = (id)[image CGImage];
	self.bounds = CGRectMake(0,0,image.size.width,image.size.height);
	
	self.masksToBounds = NO;
}

- (id) initWithKey: (NSString*) key
{
	WarnDeprecated();
	return [self initWithCGImage:[RMMarker markerImage:key]];
}

- (id) initWithStyle: (RMMarkerStyle*) style
{
	WarnDeprecated();
	return [self initWithCGImage: [style.markerIcon CGImage] anchorPoint: style.anchorPoint]; 
}

- (id) initWithNamedStyle: (NSString*) styleName
{
	WarnDeprecated();
	RMMarkerStyle* style = [[RMMarkerStyles styles] styleNamed: styleName];
	
	if (style==nil) {
		RMLog(@"problem creating marker: style '%@' not found", styleName);
		return [self initWithCGImage: [RMMarker markerImage: RMMarkerRedKey]];
	}
	return [self initWithStyle: style];
}

- (void) setLabel: (UIView*)aView
{
	if (self.labelView == aView) {
		return;
	}

	if (labelView != nil)
	{
		[[self.labelView layer] removeFromSuperlayer];
		self.labelView = nil;
	}
	
	if (aView != nil)
	{
		self.labelView = [aView retain];
		[self addSublayer:[self.labelView layer]];
	}
}

/// \deprecated after 0.5.  Use changeLabelUsingText
- (void) setTextLabel: (NSString*)text
{
	WarnDeprecated();
	[self changeLabelUsingText:text];
}

/// \deprecated after 0.5.  Use changeLabelUsingText
- (void) setTextLabel: (NSString*)text toPosition:(CGPoint)position
{
	WarnDeprecated();
	[self changeLabelUsingText:text toPosition:position];
}

/// \deprecated after 0.5.  Use changeLabelUsingText
- (void) setTextLabel: (NSString*)text withFont:(UIFont*)font withTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)backgroundColor
{
	WarnDeprecated();
	[self changeLabelUsingText:text withFont:font withTextColor:textColor withBackgroundColor:backgroundColor];
}

/// \deprecated after 0.5.  Use changeLabelUsingText
- (void) setTextLabel: (NSString*)text toPosition:(CGPoint)position withFont:(UIFont*)font withTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)backgroundColor
{
	WarnDeprecated();
	[self changeLabelUsingText:text toPosition:position withFont:font withTextColor:textColor withBackgroundColor:backgroundColor];
}

- (void) changeLabelUsingText: (NSString*)text
{
	CGPoint position = CGPointMake([self bounds].size.width / 2 - [text sizeWithFont:[UIFont systemFontOfSize:15]].width / 2, 4);
	[self changeLabelUsingText:text toPosition:position withFont:[UIFont systemFontOfSize:15] withTextColor:[self textForegroundColor] withBackgroundColor:[self textBackgroundColor]];
}

- (void) changeLabelUsingText: (NSString*)text toPosition:(CGPoint)position
{
	[self changeLabelUsingText:text toPosition:position withFont:[UIFont systemFontOfSize:15] withTextColor:[self textForegroundColor] withBackgroundColor:[self textBackgroundColor]];
}

- (void) changeLabelUsingText: (NSString*)text withFont:(UIFont*)font withTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)backgroundColor
{
	CGPoint position = CGPointMake([self bounds].size.width / 2 - [text sizeWithFont:font].width / 2, 4);
	[self setTextForegroundColor:textColor];
	[self setTextBackgroundColor:backgroundColor];
	[self changeLabelUsingText:text  toPosition:position withFont:font withTextColor:textColor withBackgroundColor:backgroundColor];
}

- (float)calculateHeightOfTextFromWidth:(NSString*)text withFont:(UIFont *)withFont forWidth:(float)width withLineBreakMode:(UILineBreakMode)lineBreakMode
{
	[text retain];
	[withFont retain];
	CGSize suggestedSize = [text sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	[text release];
	[withFont release];
	
	return suggestedSize.height;
}


- (void) changeLabelUsingText: (NSString*)text toPosition:(CGPoint)position withFont:(UIFont*)font withTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)backgroundColor
{
	CGSize textSize = [text sizeWithFont:font];
	float widthSuggestion = 200.0;
	
	float heightSuggestion = [self calculateHeightOfTextFromWidth:text withFont:font forWidth:widthSuggestion withLineBreakMode:UILineBreakModeWordWrap];
	if (heightSuggestion/textSize.height < 2)
	{
		widthSuggestion = textSize.width;
	}
	
	CGRect frame = CGRectMake(position.x,
							  position.y-heightSuggestion,
							  widthSuggestion+4,
							  heightSuggestion+4);
	
	UILabel *aLabel = [[UILabel alloc] initWithFrame:frame];
	[self setTextForegroundColor:textColor];
	[self setTextBackgroundColor:backgroundColor];
	[aLabel setNumberOfLines:0];
	[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[aLabel setBackgroundColor:backgroundColor];
	[aLabel setTextColor:textColor];
	[aLabel setFont:font];
	[aLabel setTextAlignment:UITextAlignmentCenter];
	[aLabel setText:text];
	
	[self setLabel:aLabel];
	[aLabel release];
}

- (void) removeLabel
{
	if (self.labelView != nil)
	{
		[[self.labelView layer] removeFromSuperlayer];
		self.labelView = nil;
	}

}
		
- (void) toggleLabel
{
	if (self.labelView == nil) {
		return;
	}
	
	if ([self.labelView isHidden]) {
		[self showLabel];
	} else {
		[self hideLabel];
	}
}

- (void) showLabel
{
	if ([self.labelView isHidden]) {
		// Using addSublayer will animate showing the label, whereas setHidden is not animated
		[self addSublayer:[self.labelView layer]];
		[self.labelView setHidden:NO];
	}
}

- (void) hideLabel
{
	if (![self.labelView isHidden]) {
		// Using removeFromSuperlayer will animate hiding the label, whereas setHidden is not animated
		[[self.labelView layer] removeFromSuperlayer];
		[self.labelView setHidden:YES];
	}
}

- (void) dealloc 
{
    self.data = nil;
    self.labelView = nil;
    self.textForegroundColor = nil;
    self.textBackgroundColor = nil;
	[super dealloc];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	self.position = RMScaleCGPointAboutPoint(self.position, zoomFactor, center);
	
/*	CGRect currentRect = CGRectMake(self.position.x, self.position.y, self.bounds.size.width, self.bounds.size.height);
	CGRect newRect = RMScaleCGRectAboutPoint(currentRect, zoomFactor, center);
	self.position = newRect.origin;
	self.bounds = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
*/
}

+ (CGImageRef) loadPNGFromBundle: (NSString *)filename
{
	WarnDeprecated();
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"png"];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path UTF8String]);
	CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
	/// \bug FIXME: there is no GC on iPhone! NSMakeCollectable???
	[NSMakeCollectable(image) autorelease];
	CGDataProviderRelease(dataProvider);
	
	return image;
}

+ (CGImageRef) markerImage: (NSString *) key
{
	WarnDeprecated();
	if (RMMarkerBlueKey == key
		|| [RMMarkerBlueKey isEqualToString:key])
	{
		if (_markerBlue == nil)
			_markerBlue = [self loadPNGFromBundle:@"marker-blue"];
		
		return _markerBlue;
	}
	else if (RMMarkerRedKey == key
		|| [RMMarkerRedKey isEqualToString: key])
	{
		if (_markerRed == nil)
			_markerRed = [self loadPNGFromBundle:@"marker-red"];
		
		return _markerRed;
	}
	
	return nil;
}

- (void) hide 
{
	WarnDeprecated();
	[self setHidden:YES];
}

- (void) unhide
{
	WarnDeprecated();
	[self setHidden:NO];
}


/*- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[label setAlpha:1.0f - [label alpha]];
//	[self changeLabelUsingText:@"hello there"];
	//	RMLog(@"marker at %f %f m %f %f touchesEnded", self.position.x, self.position.y, location.x, location.y);
}*/

@end
