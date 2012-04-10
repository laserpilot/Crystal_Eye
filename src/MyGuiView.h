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
    
	testApp *myApp;		// points to our instance of testApp
}

-(void)setStatusString:(NSString *)trackStr;

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
