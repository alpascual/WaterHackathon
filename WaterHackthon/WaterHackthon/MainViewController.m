//
//  MainViewController.m
//  WaterHackthon
//
//  Created by Al Pascual on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize mapView = _mapView;
@synthesize waterSourceFeatureLayer = _waterSourceFeatureLayer;
@synthesize dwellingFeatureLayer = _dwellingFeatureLayer;
@synthesize devicesFeatureLayer = _devicesFeatureLayer;
@synthesize theNewFeature = _theNewFeature;
@synthesize sketchLayer = _sketchLayer;
@synthesize selectedFeatureLayer = _selectedFeatureLayer;
@synthesize deviceTimer = _deviceTimer;
@synthesize lastPoint = _lastPoint;
@synthesize crumbsFeatureLayer = _crumbsFeatureLayer;
@synthesize crumbsTimer = _crumbsTimer;
@synthesize lastPointCrumb = _lastPointCrumb;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"Water Hackathon";

    // Wrap Around the world
    self.mapView.wrapAround = YES;
    self.mapView.layerDelegate = self;
    self.mapView.gps.autoPan = TRUE;
    
    // Load the map
    AGSOpenStreetMapLayer *openSteetMap = [[AGSOpenStreetMapLayer alloc] init];
    [self.mapView addMapLayer:openSteetMap withName:@"BaseLayer"];
    
    // Init FeatureServices
    NSURL* waterSourceUrl = [NSURL URLWithString:@"http://hydro.esri.com/ArcGIS/rest/services/WaterSource/FeatureServer/0"]; 	 
    self.waterSourceFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL: waterSourceUrl mode: AGSFeatureLayerModeSnapshot];
    self.waterSourceFeatureLayer.infoTemplateDelegate = self.waterSourceFeatureLayer;
    self.waterSourceFeatureLayer.outFields = [NSArray arrayWithObject:@"*"];
    [self.mapView addMapLayer:self.waterSourceFeatureLayer withName:@"watersource"];
    
    NSURL* dwellingUrl = [NSURL URLWithString:@"http://hydro.esri.com/ArcGIS/rest/services/WaterSource/FeatureServer/1"]; 	 
    self.dwellingFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:dwellingUrl mode: AGSFeatureLayerModeSnapshot];
    self.dwellingFeatureLayer.infoTemplateDelegate = self.dwellingFeatureLayer;
    self.dwellingFeatureLayer.outFields = [NSArray arrayWithObject:@"*"];
    [self.mapView addMapLayer:self.dwellingFeatureLayer withName:@"dwelling"]; 
    
    // Devices
    NSURL* devicesUrl = [NSURL URLWithString:@"http://hydro.esri.com/ArcGIS/rest/services/WaterSource/FeatureServer/2"]; 	 
    self.devicesFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:devicesUrl mode: AGSFeatureLayerModeSelection];
    self.devicesFeatureLayer.infoTemplateDelegate = self.devicesFeatureLayer;
    self.devicesFeatureLayer.outFields = [NSArray arrayWithObject:@"*"];
    
    // Do not show yourself in the map
    NSString *theQueryString = [[NSString alloc] initWithFormat:@"NAME != '%@'", [[UIDevice currentDevice] name]];
    AGSQuery* query = [AGSQuery query]; 
    query.where = theQueryString;
    [self.devicesFeatureLayer selectFeaturesWithQuery:query selectionMethod:AGSFeatureLayerSelectionMethodAdd];
    
    [self.mapView addMapLayer:self.devicesFeatureLayer withName:@"devices"];
    
    // BreadCumbs
    NSURL* crumbsUrl = [NSURL URLWithString:@"http://hydro.esri.com/ArcGIS/rest/services/WaterSource/FeatureServer/3"]; 	 
    self.crumbsFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:crumbsUrl mode: AGSFeatureLayerModeSnapshot];
    self.crumbsFeatureLayer.infoTemplateDelegate = self.crumbsFeatureLayer;
    self.crumbsFeatureLayer.outFields = [NSArray arrayWithObject:@"*"];   
     
       
}


- (void) mapViewDidLoad:(AGSMapView *)mapView {
    [self.mapView.gps start];
    
    self.mapView.calloutDelegate = self;
    self.lastPoint = nil;
    
    // Timers to update the gps is available
    self.deviceTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(storeDevicePosition:) userInfo:nil repeats:YES];
    
    self.crumbsTimer = [NSTimer scheduledTimerWithTimeInterval:(60.0 * 10) target:self selector:@selector(storeDevicePositionCrumbs:) userInfo:nil repeats:YES];
}

- (void)storeDevicePosition:(NSTimer *)timer
{
    if ( self.mapView.gps.enabled == YES )
    {
        AGSPoint *point = [self.mapView.gps currentPoint];
        
        if ( point.x != self.lastPoint.x) {    
            
            // Delete previous points
            NSString *theQueryString = [[NSString alloc] initWithFormat:@"NAME = '%@'", [[UIDevice currentDevice] name]];
            [self.devicesFeatureLayer deleteFeaturesWithWhereClause:theQueryString geometry:self.mapView.fullEnvelope spatialRelation:AGSSpatialRelationshipWithin];
            
            // Add the last
            AGSGraphic *graphic = [[AGSGraphic alloc] init];
            graphic.geometry = point;       
            graphic.attributes = [[NSMutableDictionary alloc] init];
            [graphic.attributes setObject:[[UIDevice currentDevice] name] forKey:@"NAME"]; 
            
            /*NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"M/d/yyyy h:mm a"];
            NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];                        
            [graphic.attributes setObject:dateString forKey:@"SAMPLETIME"];*/
            
            NSArray *array = [[NSArray alloc] initWithObjects:graphic, nil];
            [self.devicesFeatureLayer addFeatures:array];
            self.lastPoint = point;
        }
    }
}

- (void)storeDevicePositionCrumbs:(NSTimer *)timer
{
    if ( self.mapView.gps.enabled == YES )
    {
        AGSPoint *point = [self.mapView.gps currentPoint];
        
        if ( point.x != self.lastPointCrumb.x) {             
            // Add the last
            AGSGraphic *graphic = [[AGSGraphic alloc] init];
            graphic.geometry = point;       
            graphic.attributes = [[NSMutableDictionary alloc] init];
            [graphic.attributes setObject:[[UIDevice currentDevice] name] forKey:@"NAME"]; 
            
            /*NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"M/d/yyyy h:mm a"];
            NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];                        
            [graphic.attributes setObject:dateString forKey:@"SAMPLETIME"];*/
            
            NSArray *array = [[NSArray alloc] initWithObjects:graphic, nil];
            [self.crumbsFeatureLayer addFeatures:array];
            self.lastPointCrumb = point;
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

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

//
// Call the callout and show the attributes for editing
//
- (void)mapView:(AGSMapView *)mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *)graphic
{
	
    self.theNewFeature = graphic;
    bNewFeature = NO;
    self.selectedFeatureLayer = (AGSFeatureLayer*) [graphic layer];
    
    AGSPopupInfo *info = [AGSPopupInfo popupInfoForGraphic:self.theNewFeature];
    AGSPopupsContainerViewController *pop = [[AGSPopupsContainerViewController alloc] initWithPopupInfo:info graphic:self.theNewFeature usingNavigationControllerStack:NO];
    
    pop.delegate = self;
    
    if ( [[UIDevice currentDevice] isIPad] ) 
        pop.modalPresentationStyle = UIModalPresentationFormSheet;  
    
    else 
        pop.modalTransitionStyle =  UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:pop animated:YES];
    [pop startEditingCurrentPopup];
}

- (IBAction)addNewFeatureType:(id)sender
{
    bNewFeature = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FeatureTypeViewController *controller = [[FeatureTypeViewController alloc] initWithNibName:@"FeatureTypeViewController" bundle:nil];
        
        controller.waterSourceFeatureLayer = self.waterSourceFeatureLayer;
		controller.dwellingFeatureLayer = self.dwellingFeatureLayer;
                
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        self.flipsidePopoverController = nil;
        if (!self.flipsidePopoverController) {
            FeatureTypeViewController *controller = [[FeatureTypeViewController alloc] initWithNibName:@"FeatureTypeViewController" bundle:nil];
            
            controller.waterSourceFeatureLayer = self.waterSourceFeatureLayer;
            controller.dwellingFeatureLayer = self.dwellingFeatureLayer;
            
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
        controller.mapView = self.mapView;
        controller.crumbsFeatureLayer = self.crumbsFeatureLayer;
        
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        self.flipsidePopoverController = nil;
        if (!self.flipsidePopoverController) {
            FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];            
            controller.mapView = self.mapView;
            controller.crumbsFeatureLayer = self.crumbsFeatureLayer;
            
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

// Add Features
// Add new feature on the first feature service
- (void)flipFeaturesControllerDidFinish:(FeatureTypeViewController *)controller
{    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
    
    self.selectedFeatureLayer = controller.selectedFeatureLayer;
    
    //create new feature
    self.theNewFeature = controller.feature;
    
        
    //create a sketch layer
    self.sketchLayer = [[AGSSketchGraphicsLayer alloc]initWithGeometry:nil];
    
    //set the geometry of the sketch layer
    if(self.selectedFeatureLayer.geometryType == AGSGeometryTypePoint)
    {
        self.sketchLayer.geometry = [[AGSMutablePoint alloc] initWithSpatialReference:self.mapView.spatialReference];
        
        // if its a point, just save it
        
        
    }
    else if(self.selectedFeatureLayer.geometryType == AGSGeometryTypePolyline)
    {
        self.sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
    }
    else if(self.selectedFeatureLayer.geometryType == AGSGeometryTypePolygon)
    {
        self.sketchLayer.geometry = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
    }
    
    //add the sketch layer to the map and set the touch delegate
    //self.mapView.touchDelegate = self.sketchLayer;
    self.mapView.touchDelegate = self;
    
    [self.mapView addMapLayer:self.sketchLayer withName:@"sketch"];
    
}

- (void) mapView:		(AGSMapView *) 	mapView
 didClickAtPoint:		(CGPoint) 	screen
        mapPoint:		(AGSPoint *) 	mappoint
        graphics:		(NSDictionary *) 	graphics
{
    
    AGSFeatureLayer *featureLayer = self.selectedFeatureLayer;
    
    if ( self.theNewFeature != nil )
    {
        //save the geometry
        self.theNewFeature.geometry = mappoint;
        [featureLayer addGraphic:self.theNewFeature];
        [featureLayer dataChanged];
    }
    
    //add a callout for the new feature that will be used to launch the popup
    AGSCalloutTemplate *sketchCallout = [[AGSCalloutTemplate alloc]init];
    sketchCallout.titleTemplate = [[self.selectedFeatureLayer.templates objectAtIndex:0] name];
    sketchCallout.detailTemplate = @"Click the accessory button to edit attributes";
    self.theNewFeature.infoTemplateDelegate = sketchCallout;
    
    // Old show call out
    [self.mapView showCalloutAtPoint:(AGSPoint *) self.theNewFeature.geometry forGraphic:self.theNewFeature animated:NO];
    
    //remove the sketch layer
    [self.mapView removeMapLayerWithName:@"sketch"];
    self.sketchLayer = nil;    
    self.mapView.touchDelegate = nil;  
    
   
    AGSPopupInfo *info = [AGSPopupInfo popupInfoForGraphic:self.theNewFeature];
    AGSPopupsContainerViewController *pop = [[AGSPopupsContainerViewController alloc] initWithPopupInfo:info graphic:self.theNewFeature usingNavigationControllerStack:NO];
        
    pop.delegate = self;
    
    if ( [[UIDevice currentDevice] isIPad] ) 
        pop.modalPresentationStyle = UIModalPresentationFormSheet;  
        
    else 
        pop.modalTransitionStyle =  UIModalTransitionStyleCoverVertical;
   
    [self presentModalViewController:pop animated:YES];
    [pop startEditingCurrentPopup];
    
}



- (void)popupsContainerDidFinishViewingPopups:(id) popupsContainer {
    
    NSArray *array = [[NSArray alloc] initWithObjects:self.theNewFeature, nil];
    
    if ( bNewFeature == YES )
        [self.selectedFeatureLayer addFeatures:array];
    else
        [self.selectedFeatureLayer updateFeatures:array];
    
    [self dismissModalViewControllerAnimated:YES];
}



@end
