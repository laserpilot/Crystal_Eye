//
//  MyGuiView.m
//  iPhone Empty Example
//
//  Created by theo on 26/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  Modified by Blair Neal - 2012

#import "MyGuiView.h"
#include "ofxiPhoneExtras.h"


@implementation MyGuiView

// called automatically after the view is loaded, can be treated like the constructor or setup() of this class
-(void)viewDidLoad {
	myApp = (testApp*)ofGetAppPtr();
    if([UIDevice currentDevice].orientation == 0 || 
       [UIDevice currentDevice].orientation == 1 || 
       [UIDevice currentDevice].orientation == 2 ||
       [UIDevice currentDevice].orientation == 3 || 
       [UIDevice currentDevice].orientation == 5 || 
       [UIDevice currentDevice].orientation == 6)
    {

 
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation((M_PI * (90) / 180.0)); 
        self.view.bounds = CGRectMake(-320, -240, 960,640);
        cout<< "HEY" << endl;
    }
    
    else {
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation((M_PI * (-90) / 180.0)); 
        self.view.bounds = CGRectMake(-320, -240, 960,640);
        cout << "HO" << endl;
    }

  /*
     if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation((M_PI * (-90) / 180.0)); 
        self.view.bounds = CGRectMake(-240, -320, 960,640);
    }*/
}
    

//----------------------------------------------------------------
-(void)setStatusString:(NSString *)trackStr{
	displayText.text = trackStr;
}

//----------------------------------------------------------------
-(void)setHelpString:(NSString *)trackStr{
	helpText.text = trackStr;
}


//----------------------------------------------------------------
-(IBAction)hide:(id)sender{
	self.view.hidden = YES;
}

//----------------------------------------------------------------
-(IBAction)adjustThresh:(id)sender{
	
	UISlider * slider = sender;
	printf("Thresh value is - %f\n", [slider value]);
	
	myApp->threshold = [slider value] * 255;
	
	string statusStr = " Status: Threshold is " + ofToString(myApp->threshold);
	[self setStatusString:ofxStringToNSString(statusStr)];
	
}

//----------------------------------------------------------------
-(IBAction)adjustBlur:(id)sender{
	
	UISlider * slider = sender;
	printf("Blur value is - %f\n", [slider value]);
	
	myApp->blurAmt = [slider value] * 255;
	
	string statusStr = " Status: Blur is " + ofToString(myApp->blurAmt);
	[self setStatusString:ofxStringToNSString(statusStr)];
	
}

//----------------------------------------------------------------
-(IBAction)adjustThick:(id)sender{
	
	UISlider * slider = sender;
	printf("Thickness value is - %f\n", [slider value]);
	
	myApp->lineThick = [slider value];
	
	string statusStr = " Status: Thickness is " + ofToString(myApp->lineThick);
	[self setStatusString:ofxStringToNSString(statusStr)];
	
}

//----------------------------------------------------------------
-(IBAction)adjustMystery:(id)sender{
	
	UISlider * slider = sender;
	printf("Mystery value is - %f\n", [slider value]);
	
	myApp->mystery = [slider value];
	
	string statusStr = " Status: Mystery is " + ofToString(myApp->mystery);
	[self setStatusString:ofxStringToNSString(statusStr)];
	
}

//----------------------------------------------------------------
-(IBAction)adjustMystery2:(id)sender{
	
	UISlider * slider = sender;
	printf("Mystery2 value is - %f\n", [slider value]);
	
	myApp->mystery2 = [slider value];
	
	string statusStr = " Status: Mystery2 is " + ofToString(myApp->mystery2);
	[self setStatusString:ofxStringToNSString(statusStr)];
	
}
//----------------------------------------------------------------
-(IBAction)adjustExposure:(id)sender{
	
	UISlider * slider = sender;
	printf("Exposure value is - %f\n", [slider value]);
	
	myApp->exposure = [slider value] * 255;
	
	string statusStr = " Status: Exposure is " + ofToString(myApp->exposure);
    //Include warning about long exposure times
	[self setStatusString:ofxStringToNSString(statusStr)];
	
}


//----------------------------------------------------------------
-(IBAction)backSwitch:(id)sender{
    UISwitch * toggle = sender;
    printf("Background value is - %i\n", [toggle isOn]);
    myApp->backSwitch = [toggle isOn];
}
//----------------------------------------------------------------

-(IBAction)motionSwitch:(id)sender{
    UISwitch * toggle = sender;
    printf("Motion value is - %i\n", [toggle isOn]);
    myApp->motionDetect = [toggle isOn];
}
//----------------------------------------------------------------

-(IBAction)blendSwitch:(id)sender{
    UISwitch * toggle = sender;
    printf("Blend value is - %i\n", [toggle isOn]);
    myApp->addBlend = [toggle isOn];
}
//----------------------------------------------------------------

-(IBAction)mysterySwitch:(id)sender{
    UISwitch * toggle = sender;
    printf("Mystery value is - %i\n", [toggle isOn]);
    myApp->mysterySwitch = [toggle isOn];
}
//----------------------------------------------------------------

-(IBAction)BWSwitch:(id)sender{
    UISwitch * toggle = sender;
    printf("BW value is - %i\n", [toggle isOn]);
    myApp->BWSwitch = [toggle isOn];
}
//----------------------------------------------------------------

-(IBAction)allInfo:(id)sender{
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings description" message:@"Thickness - Line thickness\n\nThreshold - Sets where lines/shapes appear on the image \n\nMystery.1 - (depends on drawing mode) How many shapes to draw\n\nMystery.2 - (depends on drawing mode) Give it a try...\n\nExposure - Sets how many layers make up an image\n\nBackground - Turns the video background on/off\n\nBlend - Turns on/off Additive blending\n\nMystery-(depends on drawing mode)\n\nB&W - turns background black and white\n\nMotion Mode - only draws lines on things that are moving\n\nMade by Fake Love 2012.\n www.fakelove.tv\n\nMade with openFrameworks.\nwww.openframeworks.cc" delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil ];   
    [alert show];
    [alert release];
}
-(IBAction)webDisplay:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.fakelove.tv"]];
}

-(IBAction)Sel1:(id)sender{
    myApp->counter = 1;
    myApp->modeChange = true;
    
    string statusStr = " Status: Standard Mode ";
    //[slider setValue:.6];
    //[self adjustBlur:slider];
	[self setStatusString:ofxStringToNSString(statusStr)];
}

-(IBAction)Sel2:(id)sender{
    myApp->counter = 2;
    myApp->modeChange = true;
    string statusStr = " Status: Crazy Mode ";
	[self setStatusString:ofxStringToNSString(statusStr)];
}

-(IBAction)Sel3:(id)sender{
    myApp->counter = 3;
    myApp->modeChange = true;
    string statusStr = " Status: Mode Mode ";
	[self setStatusString:ofxStringToNSString(statusStr)];
}

-(IBAction)Sel4:(id)sender{
    myApp->counter = 4;
    myApp->modeChange = true;
    string statusStr = " Status: Lines Mode ";
	[self setStatusString:ofxStringToNSString(statusStr)];
}

-(IBAction)Sel5:(id)sender{
    myApp->counter = 5;
    myApp->modeChange = true;
    string statusStr = " Status: Warble Mode ";
	[self setStatusString:ofxStringToNSString(statusStr)];
}

-(IBAction)Sel6:(id)sender{
    myApp->counter = 6;
    myApp->modeChange = true;
    string statusStr = " Status: Blarg Mode ";
	[self setStatusString:ofxStringToNSString(statusStr)];
}

@end
