//
//  ViewController.h
//  MAP
//
//  Created by Shakir Zareen on 7/2/12.
//  Copyright (c) 2012 oDesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFKPageFlipper.h"

@interface ViewController : UIViewController<AFKPageFlipperDataSource>
{
    AFKPageFlipper *flipper;
}
@property (strong, nonatomic) IBOutlet UIView *page1;
@property (strong, nonatomic) IBOutlet UIView *page3;
@property (strong, nonatomic) IBOutlet UIView *page2;

@end
