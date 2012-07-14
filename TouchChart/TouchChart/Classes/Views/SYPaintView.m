//
//  SYPaintView.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "SYPaintView.h"
#import "SYGeometricMathController.h"

#pragma mark - Private Interface

@interface SYPaintView() {
    
@private
	__strong NSMutableArray *handwritingCoords_;
	__weak UIImage *currentSignatureImage_;
	float lineWidth_;
	__strong UIColor *foreColor_;
	CGPoint lastTapPoint_;
}

@property(nonatomic,strong) NSMutableArray *handwritingCoords;

- (void) processPoint:(CGPoint) touchLocation;

@end


@implementation SYPaintView

@synthesize handwritingCoords = handwritingCoords_;
@synthesize lineWidth = lineWidth_;
@synthesize foreColor = foreColor_;

#pragma mark - *** Initializers ***

- (id) initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];

    if (self) {
		self.handwritingCoords = [NSMutableArray array];
		self.lineWidth = 5.0f;
		self.foreColor = [UIColor blackColor];
		self.backgroundColor = [UIColor clearColor];
		lastTapPoint_ = CGPointZero;
    }
    
    return self;
    
}// initWithFrame:


- (void) awakeFromNib
{
    self.handwritingCoords = [NSMutableArray array];
    self.lineWidth = 5.0f;
    self.foreColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
    lastTapPoint_ = CGPointZero;
    
}// awakeFromNib



#pragma mark - Drawing

- (void) drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Set drawing params
	CGContextSetLineWidth(context, self.lineWidth);
	CGContextSetStrokeColorWithColor(context, [self.foreColor CGColor]);
	CGContextSetLineCap(context, kCGLineCapButt);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextBeginPath(context);
	
	// This flag tells us to move to the point
	// rather than draw a line to the point
	BOOL isFirstPoint = YES;
	
	// Loop through the strings in the array
	// which are just serialized CGPoints

	for (NSValue *touchString in self.handwritingCoords) {
		
		// Unserialize
		CGPoint tapLocation = [touchString CGPointValue];
		
		// If we have a CGPointZero, that means the next
		// iteration of this loop will represent the first
		// point after a user has lifted their finger.
		if (CGPointEqualToPoint(tapLocation, CGPointZero)) {
			isFirstPoint = YES;
			continue;
		}
		
		// If first point, move to it and continue. Otherwize, draw a line from
		// the last point to this one.
		if (isFirstPoint) {
			CGContextMoveToPoint(context, tapLocation.x, tapLocation.y);
			isFirstPoint = NO;
		} else {
			CGPoint startPoint = CGContextGetPathCurrentPoint(context);
			CGContextAddQuadCurveToPoint(context, startPoint.x, startPoint.y, tapLocation.x, tapLocation.y);
			CGContextAddLineToPoint(context, tapLocation.x, tapLocation.y);
		}
		
	}	
	
	// Stroke it, baby!
	CGContextStrokePath(context);
    
}// drawRect:


- (void) setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
	// Set the brush color using premultiplied alpha values
	self.foreColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
}// setBrushColorWithRed:


#pragma mark - Touch Handling

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // TEMP
    [self clearPaint];
    
    // MathController send point
    CGRect bounds = [self bounds];
    UITouch* touch = [[event touchesForView:self] anyObject];
	firstTouch = YES;
    
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
    
    // CGPoint to NSValue and add it to list
    [geometricMathController cleanData];
    [geometricMathController addFirstPoint:location];
        
}// touchesBegan:withEvent:

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self];
	
	[self processPoint:touchLocation];
    
    // MathController send point
    CGRect bounds = [self bounds];
    
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;        
	}
    else {
		location = [touch locationInView:self];
	    location.y = bounds.size.height - location.y;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y; 
        
        // Add these new points
        [geometricMathController addPoint:previousLocation andPoint:location];
	}
	
}// touchesMoved:withEvent:


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.handwritingCoords addObject:[NSValue valueWithCGPoint:CGPointZero]];
    //[self clearPaint];
    
    // Analyze a recognize the figure
    UITouch *touch = [[event touchesForView:self] anyObject];
    location = [touch locationInView:self];
    
    // Add the last point
    [geometricMathController addLastPoint:previousLocation];
    
    // Analyze a recognize the figure
    [geometricMathController getFigurePainted];
    
}// touchesEnded:withEvent:


- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.handwritingCoords addObject:[NSValue valueWithCGPoint:CGPointZero]];
    //[self clearPaint];
    
    // Analyze a recognize the figure
    UITouch *touch = [[event touchesForView:self] anyObject];
    location = [touch locationInView:self];
    
    // Add the last point
    [geometricMathController addLastPoint:previousLocation];
    
    // Analyze a recognize the figure
    [geometricMathController getFigurePainted];
    
}// touchesCancelled:withEvent:


#pragma mark - Private Methods

- (void) processPoint:(CGPoint) touchLocation
{
	// Only keep the point if it's > 5 points from the last
	if (CGPointEqualToPoint(CGPointZero, lastTapPoint_) || 
		fabs(touchLocation.x - lastTapPoint_.x) > 2.0f ||
		fabs(touchLocation.y - lastTapPoint_.y) > 2.0f) {
        
		[self.handwritingCoords addObject:[NSValue valueWithCGPoint:touchLocation]];
		[self setNeedsDisplay];
		lastTapPoint_ = touchLocation;
	}
    
}// processPoint:


#pragma mark - Public Methods

-(void) clearPaint
{
	[self.handwritingCoords removeAllObjects];
	[self setNeedsDisplay];
	
}// clearPaint

@end