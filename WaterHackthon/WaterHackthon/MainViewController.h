//
//  MainViewController.h
//  WaterHackthon
//
//  Created by Al Pascual on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "FeatureTypeViewController.h"
#import "ArcGIS.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, FlipFeaturesControllerDelegate, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSMapViewCalloutDelegate, 
    AGSFeatureLayerEditingDelegate,AGSAttachmentManagerDelegate,
    AGSInfoTemplateDelegate, AGSPopupsContainerDelegate, 
    AGSWebMapDelegate>
{
    BOOL bNewFeature;
}

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) IBOutlet AGSMapView *mapView;
@property (strong, nonatomic) AGSFeatureLayer *waterSourceFeatureLayer;
@property (strong, nonatomic) AGSFeatureLayer *dwellingFeatureLayer;
@property (strong, nonatomic) AGSFeatureLayer *devicesFeatureLayer;
@property (strong, nonatomic) AGSFeatureLayer *crumbsFeatureLayer;
@property (strong, nonatomic) AGSGraphic *theNewFeature;
@property (strong, nonatomic) AGSSketchGraphicsLayer *sketchLayer;
@property (strong) AGSFeatureLayer *selectedFeatureLayer;
@property (strong, nonatomic) NSTimer *deviceTimer;
@property (strong, nonatomic) NSTimer *crumbsTimer;
@property (strong, nonatomic) AGSPoint *lastPoint;
@property (strong, nonatomic) AGSPoint *lastPointCrumb;

- (IBAction)showInfo:(id)sender;

@end
