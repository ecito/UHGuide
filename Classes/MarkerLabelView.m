//
//  MarkerLabelView.m
//  UHCampusGuide
//
//  Created by CampusGuide on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MarkerLabelView.h"


@implementation MarkerLabelView


- (id)initWithFrame:(CGRect)frame {
// NSLog(@"Creating MarkerLabelView");
    if (self = [super initWithFrame:frame]) {
	
//	TTShapeStyle *label = [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5 pointLocation:290
//                                                      pointAngle:270
//                                                      pointSize:CGSizeMake(20,10)] next:
//    [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
//    [TTSolidBorderStyle styleWithColor:[UIColor blackColor] width:1 next:nil]]];
//    TTView* view = [[[TTView alloc] initWithFrame:frame] autorelease];
//    view.style = label;
//	[self addSubview:view];



		UILabel *name = [[UILabel alloc] initWithFrame:frame];
		name.userInteractionEnabled = NO;

		[name setText:@"SUP!"];

		name.backgroundColor = [UIColor redColor];
		[self addSubview:name];
		
		self.userInteractionEnabled = YES;
		
		

				        // Initialization code
    }
    return self;
}

- (BOOL)isFirstResponder
{
	return YES;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
// NSLog(@"Touches began!");
//    NSUInteger numTaps = [[touches anyObject] tapCount];
//	touchPhaseText.text = @"Phase: Touches began";
//	touchInfoText.text = @"";
//	if(numTaps >= 2) {
//		touchInfoText.text = [NSString stringWithFormat:@"%d taps",numTaps]; 
//		if ((numTaps == 2) && (self.piecesOnTop)) {
//			// A double tap positions the three pieces in a diagonal.
//			// The user will want to double tap when two or more pieces are on top of each other
//			if (firstPieceView.center.x == secondPieceView.center.x)
//				secondPieceView.center = CGPointMake(firstPieceView.center.x -45, firstPieceView.center.y -45);		
//			if (firstPieceView.center.x == thirdPieceView.center.x)
//				thirdPieceView.center  = CGPointMake(firstPieceView.center.x +45, firstPieceView.center.y +45);	
//			if (secondPieceView.center.x == thirdPieceView.center.x)
//				thirdPieceView.center  = CGPointMake(secondPieceView.center.x +45, secondPieceView.center.y +45);
//			touchInstructionsText.text = @"";
//		}
//	} else {
//		touchTrackingText.text = @"";
//	}
//	// Enumerate through all the touch objects.
//	NSUInteger touchCount = 0;
//	for (UITouch *touch in touches) {
//	    // Send to the dispatch method, which will make sure the appropriate subview is acted upon
//		[self dispatchFirstTouchAtPoint:[touch locationInView:self] forEvent:nil];
//		touchCount++;  
//	}	
}


- (void)dealloc {
    [super dealloc];
}


@end
