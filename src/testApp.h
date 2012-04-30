#pragma once


#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"


//ON IPHONE NOTE INCLUDE THIS BEFORE ANYTHING ELSE
#include "ofxOpenCv.h"
#include "ofxiPhoneTorch.h"

class testApp : public ofxiPhoneApp{
	
	public:
		
		void setup();
		void update();
		void draw();
        void exit();
    
        void updateMotion( unsigned char *pixels );
        void initMotion();
		
		void touchDown(ofTouchEventArgs &touch);
		void touchMoved(ofTouchEventArgs &touch);
		void touchUp(ofTouchEventArgs &touch);
		void touchDoubleTap(ofTouchEventArgs &touch);
		void touchCancelled(ofTouchEventArgs &touch);
    
        void changeOrientation(int newOrientation);
        void switchCamera();

    
		ofVideoGrabber 		vidGrabber;
    
        ofVideoPlayer       introVid;
        bool                introDone;
    
        ofxCvColorImage         colorImg;
        ofxCvGrayscaleImage     grayImg;
        ofxCvGrayscaleImage		blackwhiteImage;
        ofxCvContourFinder      contourFinder;
    
        //Motion Detection
        ofxCvGrayscaleImage		cameraGrayPrevImage;
        ofxCvGrayscaleImage		cameraGrayDiffImage;
        ofxCvFloatImage			cameraDiffFloatImage;
        ofxCvFloatImage			cameraMotionFloatImage;
        ofxCvGrayscaleImage     camMotionGray;
    
        ofImage colorHold; //For grabbing color values
    
        ofxiPhoneTorch      flashlight;
        bool                enableFlashlight;
        bool                flash;
    
        unsigned char       *motionPixels;
        float               cameraMotionFadeAmount;
        bool                motionDetect;
        
        int                 keyPress;
        
        int 				threshold;
        int                 camWidth;
        int                 camHeight;
    
        ofPoint             mapPt;
        ofPoint             nextMappedPt;
        ofPoint             mapCent;
        
        int                 ptAvg;
        int                 ptSum;
        
        
        //float               linethick;
        
        int         tog;
        int         counter; //Currently 1-4
    
        //For node connection mode - Currently not included
        int         connectDist[100][100];
        int         blobConnect[100];
        int         MysteryConnect;
        int         MysteryConnect2;
        int         connectCount;
    
    
        //Variables from gui
        int         blurAmt;
        float       lineThick;
        float       mystery;
        float       mystery2;
        bool        addBlend;
        bool        mysterySwitch;
        bool        BWSwitch;
        
        bool        backSwitch;
        bool        motionSwitch;
    
        bool        shufflin; //Everyday I'm (for randomizing app variables)
    
        //color Switching
        float       hCycle;
        ofColor     color;
        ofColor     ModColor;
        
        //Bool for taking a picture
        bool        snapPhoto;
        //Special FBO and threshold capturer
        bool        snapSpecial;
        int         threshChange;
        int         threshCounter;
        ofFbo       fboNew;
        int         exposure; //how many steps through the threshold counter?
        int         flashCounter;
    
        //Gui images
        ofImage     snapIcon;
        ofImage     camswitchIcon;
        ofImage     settingsGear;
        ofImage     specialSnap;
        ofImage     shuffleIcon;
        ofImage     fullGui;
        ofImage     fullGuiPortrait;
        ofImage     loadScreen;
        int         loadFade;
        int         fadetimeSave;
        bool        hideGui;        //when in other view mode
        bool        portraitGui;    //for altered spacing/rotation
        
        ofTrueTypeFont  codePro;
        ofTrueTypeFont  codeProLight;
        
        //Orientation and camera switching
        bool        switchCam;
        int         camState; //0 = back, 1 = front
        ofPoint     camDeform;
        ofPoint     buttonPos;
        bool        modeChange;
    
        //For swiping gestures
        string CurrentModeString;
        ofPoint     loc;
        ofPoint     compare;
        int         timer;
    
        //For DINO MODE
        ofImage     numbers[4];
        ofVec2f     a, b, tangent, normal, mappedA, mappedB;



};
