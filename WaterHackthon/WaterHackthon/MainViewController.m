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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	

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
    
    NSURL* devicesUrl = [NSURL URLWithString:@"http://hydro.esri.com/ArcGIS/rest/services/WaterSource/FeatureServer/2"]; 	 
    self.devicesFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:devicesUrl mode: AGSFeatureLayerModeSnapshot];
    self.devicesFeatureLayer.infoTemplateDelegate = self.devicesFeatureLayer;
    self.devicesFeatureLayer.outFields = [NSArray arrayWithObject:@"*"];
    [self.mapView addMapLayer:self.devicesFeatureLayer withName:@"dwelling"];
}

- (void) mapViewDidLoad:(AGSMapView *)mapView {
    [self.mapView.gps start];
    
    self.mapView.calloutDelegate = self;
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
	/*AGSPopupInfo *popupInfo = [AGSPopupInfo popupInfoForGraphic:graphic];
	if (!popupInfo){
		return;
	}
    
    [self filterPopupInfo:popupInfo];
    popupInfo.title = [graphic.attributes objectForKey:@"name"];
    popupInfo.allowEdit = NO;
    popupInfo.allowDelete = NO;
    popupInfo.allowEditGeometry = NO;
    
	// create a popup from the popupInfo and a feature
	self.currentFeatureToInspectPopup = [[[AGSPopup alloc]initWithGraphic:graphic popupInfo:popupInfo]autorelease];
    
    self.mapView.callout.hidden = YES;
    [self inspectButtonPressed:nil];*/
    
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
        if (!self.flipsidePopoverController) {
            FeatureTypeViewController *controller = [[FeatureTypeViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
            
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
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        if (!self.flipsidePopoverController) {
            FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
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
    
    //set up sketch layer
    
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
