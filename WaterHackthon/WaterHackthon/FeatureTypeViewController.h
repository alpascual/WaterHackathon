// Copyright 2011 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import <UIKit/UIKit.h>
#import "ArcGIS.h"

@class FeatureTypeViewController;

@protocol FlipFeaturesControllerDelegate
- (void)flipFeaturesControllerDidFinish:(FeatureTypeViewController *)controller;
@end

@interface FeatureTypeViewController : UITableViewController {
	
	AGSGraphic *_feature;
    
    id  _completedDelegate;
}

@property (strong) AGSFeatureLayer *waterSourceFeatureLayer;
@property (strong) AGSFeatureLayer *dwellingFeatureLayer;
@property (strong) AGSFeatureLayer *selectedFeatureLayer;
@property (nonatomic, retain) AGSGraphic *feature;

@property (strong, nonatomic) IBOutlet id <FlipFeaturesControllerDelegate> delegate;

@end
