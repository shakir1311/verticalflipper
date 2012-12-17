//
//  ViewController.m
//  MAP
//
//  Created by Shakir Zareen on 7/2/12.
//  Copyright (c) 2012 oDesk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize page1;
@synthesize page3;
@synthesize page2;

#pragma mark -
#pragma mark Data source implementation


- (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *)pageFlipper {
	return 3;
}


- (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper {
	
	if ( page == 1 )
    {
        return self.page1;
    }
    
    else if ( page == 2 )
    {
        return self.page2;
    }
    
    else if ( page == 3 )
    {
        return self.page3;
    }

    return nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	flipper = [[AFKPageFlipper alloc] initWithFrame:self.view.bounds];
	flipper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	flipper.dataSource = self;
	
	[self.view addSubview:flipper];
}

- (void)viewDidUnload
{
    [self setPage1:nil];
    [self setPage3:nil];
    [self setPage2:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
