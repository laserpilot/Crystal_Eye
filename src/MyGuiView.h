//
//  MyGuiView.h
//
//  Created by theo on 26/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "testApp.h"

@interface MyGuiView : UIViewController {
	IBOutlet UILabel *displayText;
	IBOutlet UILabel *helpText;
    IBOutlet UISlider *GUIthickness;
    IBOutlet UISlider  *GUImystery;
    IBOutlet UISlider *GUImystery2;
    IBOutlet UISlider *GUIexposure;
    IBOutlet UISlider  *GUIthresh;
    IBOutlet UISwitch *GUIbackground;
    IBOutlet UISwitch *GUIblend;
    IBOutlet UISwitch *GUImysterySw;
    IBOutlet UISwitch *GUIblackwhite;
    IBOutlet UISwitch *GUImotion;
    
    IBOutlet UISwitch *updateVals;
    
	testApp *myApp;		// points to our instance of testApp
}

@property (nonatomic, retain) IBOutlet UISlider *GUIthickness; 
@property (nonatomic, retain) IBOutlet UISlider *GUIthresh; 
@property (nonatomic, retain) IBOutlet UISlider *GUImystery; 
@property (nonatomic, retain) IBOutlet UISlider *GUImystery2; 
@property (nonatomic, retain) IBOutlet UISlider *GUIexposure; 
@property (nonatomic, retain) IBOutlet UISwitch *GUIbackground; 
@property (nonatomic, retain) IBOutlet UISwitch *GUIblend; 
@property (nonatomic, retain) IBOutlet UISwitch *GUImysterySw; 
@property (nonatomic, retain) IBOutlet UISwitch *GUIblackwhite; 
@property (nonatomic, retain) IBOutlet UISwitch *GUImotion; 
@property (nonatomic, retain) IBOutlet UISwitch *updateVals; 

-(void)setStatusString:(NSString *)trackStr;
-(void)changeGuiVals:(id)sender;

-(IBAction)adjustBlur:(id)sender;
-(IBAction)adjustThick:(id)sender;
-(IBAction)adjustThresh:(id)sender;
-(IBAction)adjustMystery:(id)sender;
-(IBAction)adjustMystery2:(id)sender;
-(IBAction)adjustExposure:(id)sender;

-(IBAction)backSwitch:(id)sender;
-(IBAction)addSwitch:(id)sender;
-(IBAction)mysterySwitch:(id)sender;
-(IBAction)motionSwitch:(id)sender;
-(IBAction)BWSwitch:(id)sender;
-(IBAction)motionSwitch:(id)sender;
-(IBAction)blendSwitch:(id)sender;

-(IBAction)allInfo:(id)sender;
-(IBAction)webDisplay:(id)sender;



-(IBAction)Sel1:(id)sender;
-(IBAction)Sel2:(id)sender;
-(IBAction)Sel3:(id)sender;
-(IBAction)Sel4:(id)sender;
-(IBAction)Sel5:(id)sender;
-(IBAction)Sel6:(id)sender;
 

-(IBAction)hide:(id)sender;

@end
