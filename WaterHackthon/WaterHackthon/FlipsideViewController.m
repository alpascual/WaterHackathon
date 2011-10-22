//
//  FlipsideViewController.m
//  WaterHackthon
//
//  Created by Al Pascual on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"

@implementation FlipsideViewController

@synthesize delegate = _delegate;
@synthesize mapView = _mapView;
@synthesize gpsSwitch = _gpsSwitch;
@synthesize baseMaps = _baseMaps;
@synthesize gpsHistory = _gpsHistory;
@synthesize crumbsFeatureLayer = _crumbsFeatureLayer;
@synthesize waterSwitch = _waterSwitch;
@synthesize waterDynamic = _waterDynamic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];	
 
    [self.gpsSwitch setOn:self.mapView.gps.enabled];
    
    NSArray *layers = [[NSArray alloc] initWithArray:[self.mapView mapLayers]];
    AGSTiledLayer *baseLayer = [layers objectAtIndex:0];
        
    if ( [baseLayer isKindOfClass:[AGSOpenStreetMapLayer class]] )
        self.baseMaps.selectedSegmentIndex = 0;
    else
        self.baseMaps.selectedSegmentIndex = 1;
    
    // Is the crumbs enabled?
    if ( [layers count] < 5 )   
        [self.gpsHistory setOn:NO];
    else {
        for (AGSFeatureLayer *featureLayer in layers) {
            if ( [featureLayer isKindOfClass:[AGSFeatureLayer class]] )
            {
                if ( [featureLayer.name isEqualToString:@"breadcrumbs"])
                    [self.gpsHistory setOn:YES];
            }
        }      
        
    }
    
    // Dynamic
    if ( [layers count] > 2 ) {
        
        for (AGSDynamicMapServiceLayer *dynamicWaterLayer in layers) {
            if ( [dynamicWaterLayer isKindOfClass:[AGSDynamicMapServiceLayer class]]) {                
                if ( [dynamicWaterLayer.name isEqualToString:@"waterlayer"] )
                    [self.waterSwitch setOn:YES];
            }
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)gpsSelected:(id)sender
{
    
    if ( self.gpsSwitch.isOn == YES )
        [self.mapView.gps start];
    else
        [self.mapView.gps stop];
    
}

- (IBAction)baseMapSwitch:(id)sender
{
    [self.mapView removeMapLayerWithName:@"BaseLayer"];
    
    if ( self.baseMaps.selectedSegmentIndex == 0 )
    {
        AGSOpenStreetMapLayer *openSteetMap = [[AGSOpenStreetMapLayer alloc] init];
        [self.mapView insertMapLayer:openSteetMap withName:@"BaseLayer" atIndex:0];       
    }
    else if ( self.baseMaps.selectedSegmentIndex == 1)
    {
        AGSTiledMapServiceLayer *tiled = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"]];
        [self.mapView insertMapLayer:tiled withName:@"BaseLayer" atIndex:0];
    }
           
    
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)gpsHistorySwitch:(id)sender {
    
    if ( self.gpsHistory.isOn == YES )
        [self.mapView addMapLayer:self.crumbsFeatureLayer withName:@"breadcrumbs"];
    else
        [self.mapView removeMapLayerWithName:@"breadcrumbs"];
}

- (IBAction)waterLayerSwitch:(id)sender {
    if ( self.waterSwitch.isOn == YES ) {
         UIView* dynamicView = [self.mapView addMapLayer:self.waterDynamic withName:@"waterlayer"];
        dynamicView.alpha = 0.6;
        
    }
        
    else {
        [self.mapView removeMapLayerWithName:@"waterlayer"];
        
    }
}

@end
