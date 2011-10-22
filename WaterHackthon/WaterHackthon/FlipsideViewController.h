//
//  FlipsideViewController.h
//  WaterHackthon
//
//  Created by Al Pascual on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcGIS.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController

@property (strong, nonatomic) IBOutlet id <FlipsideViewControllerDelegate> delegate;
@property (strong, nonatomic) AGSMapView *mapView;
@property (strong, nonatomic) AGSFeatureLayer *crumbsFeatureLayer;
@property (strong, nonatomic) IBOutlet UISwitch *gpsSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *baseMaps;
@property (strong, nonatomic) IBOutlet UISwitch *gpsHistory;

- (IBAction)done:(id)sender;

@end
