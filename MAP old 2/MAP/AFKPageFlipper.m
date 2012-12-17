//
//  AFKPageFlipper.m
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-12.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//

#import "AFKPageFlipper.h"


#pragma mark -
#pragma mark UIView helpers


@interface UIView(Extended) 

- (UIImage *) imageByRenderingView;

@end


@implementation UIView(Extended)


- (UIImage *) imageByRenderingView {
    CGFloat oldAlpha = self.alpha;
    self.alpha = 1;
    CGSize sz = self.bounds.size;

    UIGraphicsBeginImageContextWithOptions(sz, TRUE, [UIScreen mainScreen].scale);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    self.alpha = oldAlpha;
	return resultingImage;
}

@end


#pragma mark -
#pragma mark Private interface


@interface AFKPageFlipper()

@property (nonatomic,assign) UIView *currentView;
@property (nonatomic,assign) UIView *nextView;

@end


@implementation AFKPageFlipper

@synthesize tapRecognizer = _tapRecognizer;
@synthesize panRecognizer = _panRecognizer;


#pragma mark -
#pragma mark Flip functionality


- (void) initFlip {
	
	// Create screenshots of view
	
	UIImage *currentImage = [self.currentView imageByRenderingView];
	UIImage *newImage = [self.nextView imageByRenderingView];
	
	// Hide existing views
	
    
	self.currentView.alpha = 0;
	self.nextView.alpha = 0;
    
    
	
	// Create representational layers
	
	CGRect rect = self.bounds;
	//rect.size.width /= 2;
    rect.size.height /= 2;
    
    
	backgroundAnimationLayer = [CALayer layer];
	backgroundAnimationLayer.frame = self.bounds;
	backgroundAnimationLayer.zPosition = -300000;
	
	CALayer *topLayer = [CALayer layer];
	topLayer.frame = rect;
	topLayer.masksToBounds = YES;
	topLayer.contentsGravity = kCAGravityBottom;
    
    
	
	[backgroundAnimationLayer addSublayer:topLayer];
	
	rect.origin.y = rect.size.height;
    
    //self.nextView.frame = rect;
	
    CALayer *bottomLayer = [CALayer layer];
	bottomLayer.frame = rect;
	bottomLayer.masksToBounds = YES;
	bottomLayer.contentsGravity = kCAGravityTop;
    
    bottomLayer.contentsScale = [[UIScreen mainScreen] scale];
    topLayer.contentsScale = [[UIScreen mainScreen] scale];

	[backgroundAnimationLayer addSublayer:bottomLayer];
    
    backgroundAnimationLayer.contentsScale = [[UIScreen mainScreen] scale];
    
	if (flipDirection == AFKPageFlipperDirectionBottom) {
		topLayer.contents = (id) [newImage CGImage];
		bottomLayer.contents = (id) [currentImage CGImage];
	} else {
		topLayer.contents = (id) [currentImage CGImage];
		bottomLayer.contents = (id) [newImage CGImage];
	}
    
    topLayer.contentsScale = [[UIScreen mainScreen] scale];
    bottomLayer.contentsScale = [[UIScreen mainScreen] scale];
    

	[self.layer addSublayer:backgroundAnimationLayer];
	
	rect.origin.y = 0;
	
	flipAnimationLayer = [CATransformLayer layer];
	flipAnimationLayer.anchorPoint = CGPointMake(0.5, 1.0);
	flipAnimationLayer.frame = rect;
	
	[self.layer addSublayer:flipAnimationLayer];
	
	CALayer *backLayer = [CALayer layer];
	backLayer.frame = flipAnimationLayer.bounds;
	backLayer.doubleSided = NO;
	backLayer.masksToBounds = YES;
	
	[flipAnimationLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	frontLayer.frame = flipAnimationLayer.bounds;
	frontLayer.doubleSided = NO;
	frontLayer.masksToBounds = YES;
	frontLayer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0);
	
	[flipAnimationLayer addSublayer:frontLayer];
	
	if (flipDirection == AFKPageFlipperDirectionBottom) {
		backLayer.contents = (id) [currentImage CGImage];
		backLayer.contentsGravity = kCAGravityBottom;
		
		frontLayer.contents = (id) [newImage CGImage];
		frontLayer.contentsGravity = kCAGravityTop;
		
		CATransform3D transform = CATransform3DMakeRotation(0.0, 1.0, 0.0, 0.0);
		transform.m34 = 1.0f / 1200.0f;
		
		flipAnimationLayer.transform = transform;
		
		currentAngle = startFlipAngle = 0;
		endFlipAngle = -M_PI;
	} else {
		backLayer.contentsGravity = kCAGravityBottom;
		backLayer.contents = (id) [newImage CGImage];
		
		frontLayer.contents = (id) [currentImage CGImage];
		frontLayer.contentsGravity = kCAGravityTop;
		
		CATransform3D transform = CATransform3DMakeRotation(-M_PI / 1.1, 1.0, 0.0, 0.0);
		transform.m34 = 1.0f / 1200.0f;
		
		flipAnimationLayer.transform = transform;
		
		currentAngle = startFlipAngle = -M_PI;
		endFlipAngle = 0;
	}
    
    
    
    backLayer.contentsScale = [[UIScreen mainScreen] scale];
    frontLayer.contentsScale = [[UIScreen mainScreen] scale];
    
    
    shadowLayer = [CALayer layer];
    if ( flipDirection == AFKPageFlipperDirectionTop )
    {
    shadowLayer.frame = bottomLayer.bounds;
    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    shadowLayer.shadowOpacity = 0.5;
    shadowLayer.shadowRadius = 75;
    shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:bottomLayer.bounds];
    shadowLayer.shadowPath = path.CGPath;
    
    [bottomLayer addSublayer:shadowLayer];
    }
    else 
    {
        shadowLayer.frame = topLayer.bounds;
        shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
        shadowLayer.shadowOpacity = 0.3;
        shadowLayer.shadowRadius = 75;
        shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:topLayer.bounds];
        shadowLayer.shadowPath = path.CGPath;
        
        [topLayer addSublayer:shadowLayer];
        
    }
    
}


- (void) cleanupFlip {
	[backgroundAnimationLayer removeFromSuperlayer];
	[flipAnimationLayer removeFromSuperlayer];
	
	backgroundAnimationLayer = Nil;
	flipAnimationLayer = Nil;
	
	animating = NO;
	
	if (setNextViewOnCompletion) {
		[self.currentView removeFromSuperview];
		self.currentView = self.nextView;
		//self.nextView = Nil;
	} else {
		[self.nextView removeFromSuperview];
		//self.nextView = Nil;
        
	}

	self.currentView.alpha = 1;
    
    self.currentView.frame = self.bounds;
    
    if ( self.subviews.count == 0 )
    {
        [self addSubview:nextView];
    }
    self.nextView = nil;
    
    [self setUserInteractionEnabled:TRUE];
    
}

- (void) setFlipProgress:(float) progress setDelegate:(BOOL) setDelegate animate:(BOOL) animate {
    if (animate) {
        animating = YES;
    }
    
	float newAngle = startFlipAngle + progress * (endFlipAngle - startFlipAngle);
	
	float duration = animate ? 0.5 * fabs((newAngle - currentAngle) / (endFlipAngle - startFlipAngle)) : 0;
	
	currentAngle = newAngle;
	
	CATransform3D endTransform = CATransform3DIdentity;
	endTransform.m34 = 1.0f / -1200.0f;
	endTransform = CATransform3DRotate(endTransform, newAngle, 1.0, 0.0, 0.0);	
	
	[flipAnimationLayer removeAllAnimations];
						
	[self setUserInteractionEnabled:FALSE];
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
    CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [CATransaction setAnimationTimingFunction:timing];
    flipAnimationLayer.transform = endTransform;
	
	[CATransaction commit];
    
    
    
    if ( progress == 1 || progress == 0 )
    {
        shadowLayer.opacity = 0;
    }
    
    if ( progress > 0.4 )
    {
        shadowLayer.opacity = 0;
    }
    else 
    {
        shadowLayer.opacity = 1-progress;
        
    }
    
	if (setDelegate) {
		[self performSelector:@selector(cleanupFlip) withObject:Nil afterDelay:duration];
	}
}


- (void) flipPage {
	[self setFlipProgress:1.0 setDelegate:YES animate:YES];
}


#pragma mark -
#pragma mark Animation management


- (void)animationDidStop:(NSString *) animationID finished:(NSNumber *) finished context:(void *) context {
	[self cleanupFlip];
}


#pragma mark -
#pragma mark Properties

@synthesize currentView;


- (void) setCurrentView:(UIView *) value {
	
	
	currentView = value;
}


@synthesize nextView;


- (void) setNextView:(UIView *) value {

	
	nextView = value;
}


@synthesize currentPage;


- (BOOL) doSetCurrentPage:(NSInteger) value {
	if (value == currentPage) {
		return FALSE;
	}
	
	flipDirection = value < currentPage ? AFKPageFlipperDirectionBottom : AFKPageFlipperDirectionTop;
	
	currentPage = value;
	
	self.nextView = [self.dataSource viewForPage:value inFlipper:self];
	[self addSubview:self.nextView];
	
	return TRUE;
}	

- (void) setCurrentPage:(NSInteger) value {
	if (![self doSetCurrentPage:value]) {
		return;
	}
	
	setNextViewOnCompletion = YES;
	animating = YES;
	
    
	self.nextView.alpha = 0;
	
	[UIView beginAnimations:@"" context:Nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
    
	self.nextView.alpha = 1;
     
	
	[UIView commitAnimations];
} 


- (void) setCurrentPage:(NSInteger) value animated:(BOOL) animated {
	if (![self doSetCurrentPage:value]) {
		return;
	}
	
	setNextViewOnCompletion = YES;
	animating = YES;
	
	if (animated) {
		[self initFlip];
		[self performSelector:@selector(flipPage) withObject:Nil afterDelay:0.001];
	} else {
		[self animationDidStop:Nil finished:[NSNumber numberWithBool:NO] context:Nil];
	}

}


@synthesize dataSource;


- (void) setDataSource:(NSObject <AFKPageFlipperDataSource>*) value {

	
	dataSource = value;
	numberOfPages = [dataSource numberOfPagesForPageFlipper:self];
    currentPage = 0;
	self.currentPage = 1;

    
    
}




@synthesize disabled;


- (void) setDisabled:(BOOL) value {
	disabled = value;
	
	self.userInteractionEnabled = !value;
	
	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
		recognizer.enabled = !value;
	}
}


#pragma mark -
#pragma mark Touch management


- (void) tapped:(UITapGestureRecognizer *) recognizer {
	if (animating || self.disabled) {
		return;
	}
	
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		NSInteger newPage;
		
		if ([recognizer locationInView:self].y < (self.bounds.size.width - self.bounds.origin.y) / 2) {
			newPage = MAX(1, self.currentPage - 1);
		} else {
			newPage = MIN(self.currentPage + 1, numberOfPages);
		}
		
		[self setCurrentPage:newPage animated:YES];
	}
}


- (void) panned:(UIPanGestureRecognizer *) recognizer {
    if (animating) {
        return;
    }
    
	static BOOL hasFailed;
	static BOOL initialized;
	
	static NSInteger oldPage;

	float translation = [recognizer translationInView:self].y;
	
	float progress = translation / self.bounds.size.width;
	
	if (flipDirection == AFKPageFlipperDirectionTop) {
		progress = MIN(progress, 0);
	} else {
		progress = MAX(progress, 0);
	}
    
    
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			hasFailed = FALSE;
			initialized = FALSE;
			animating = NO;
			setNextViewOnCompletion = NO;
			break;
			
			
		case UIGestureRecognizerStateChanged:
			
			if (hasFailed) {
				return;
			}
			
			if (!initialized) {
				oldPage = self.currentPage;
				
				if (translation > 0) {
					if (self.currentPage > 1) {
						[self doSetCurrentPage:self.currentPage - 1];
					} else {
						hasFailed = TRUE;
						return;
					}
				} else {
					if (self.currentPage < numberOfPages) {
						[self doSetCurrentPage:self.currentPage + 1];
					} else {
						hasFailed = TRUE;
						return;
					}
				}
				
				hasFailed = NO;
				initialized = TRUE;
				setNextViewOnCompletion = NO;
				
				[self initFlip];
			}
			
			[self setFlipProgress:fabs(progress) setDelegate:NO animate:NO];
			
			break;
			
			
		case UIGestureRecognizerStateFailed:
			[self setFlipProgress:0.0 setDelegate:YES animate:YES];
			currentPage = oldPage;
			break;
			
		case UIGestureRecognizerStateRecognized:
			if (hasFailed) {
				[self setFlipProgress:0.0 setDelegate:YES animate:YES];
				currentPage = oldPage;
				
				return;
			}
			
			if (fabs((translation + [recognizer velocityInView:self].y / 4) / self.bounds.size.height) > 0.5) {
				setNextViewOnCompletion = YES;
				[self setFlipProgress:1.0 setDelegate:YES animate:YES];
			} else {
				[self setFlipProgress:0.0 setDelegate:YES animate:YES];
				currentPage = oldPage;
			}

			break;
		default:
			break;
	}
}


#pragma mark -
#pragma mark Frame management


- (void) setFrame:(CGRect) value {
	super.frame = value;

	numberOfPages = [dataSource numberOfPagesForPageFlipper:self];
	
	if (self.currentPage > numberOfPages) {
		self.currentPage = numberOfPages;
	}
	
}


#pragma mark -
#pragma mark Initialization and memory management


+ (Class) layerClass {
	return [CATransformLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
		
		[self addGestureRecognizer:_panRecognizer];
    }
    return self;
}


- (void)dealloc {
	self.dataSource = Nil;
	self.currentView = Nil;
	self.nextView = Nil;
	self.tapRecognizer = Nil;
	self.panRecognizer = Nil;

}


@end
