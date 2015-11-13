#include "ofApp.h"
#include "MyGuiView.h"

//warning video player doesn't currently work - use live video only
#define _USE_LIVE_VIDEO

MyGuiView * myGuiViewController;

/*
 TO DO
    -Enable masking via the contour lines
    -Enable color picker
    -Enable Invert selection?
    -Play with connecting lines between blobs...randomly store points in an array and read them back
    -Fix weird aspect ratio/enable higher rez camera, but lower rez contour finding
 
    -Have an option for higher rez images but slower performance
 
    -Implement tap to dismiss photos
 
    -FIX ALL ORIENTATION ISSUES - still not done for front facing camera
 */
/*
 Crystal Eye
 Programming by Blair Neal and Caitlin Morris - 2012
 Menu/GUI design by Layne Braunstein
 
 Fake Love 2012
 www.fakelove.tv
 */


//--------------------------------------------------------------
void ofApp::setup(){	
    
    //Iphone Specific setup

	ofSetOrientation(OF_ORIENTATION_90_LEFT);
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    ofRegisterTouchEvents(this);

    myGuiViewController	= [[MyGuiView alloc] initWithNibName:@"MyGuiView" bundle:nil];
    [ofxiOSGetGLParentView() addSubview:myGuiViewController.view];

  
    myGuiViewController.view.hidden = YES;
    //ofSetFrameRate(30);
    
    // OF specific stuff
    vidGrabber.setVerbose(true);
    vidGrabber.setDeviceID(0); //Back camera first
    vidGrabber.setup(480*2,320*2); //Available resolutions:
    vidGrabber.listDevices();
    camWidth = vidGrabber.getWidth();
    camHeight = vidGrabber.getHeight();
    
    colorImg.allocate(camWidth,camHeight);
	grayImg.allocate(camWidth,camHeight);
    blackwhiteImage.allocate(camWidth, camHeight);

    //Image Loading
    snapIcon.load("images/camIcon.png");
    camswitchIcon.load("images/Switching-ICON.png");
    settingsGear.load("images/Gear.png");
    specialSnap.load("images/camSpecialIcon.png");
    fullGui.load("images/fl_app_front_menu.png");
    fullGuiPortrait.load("images/fl_app_menu_2_portrait.png");
    loadScreen.load("images/loadScreenland.png");
    
    sphere_oid.load("images/Blorp3.png");
    gradSquare.load("images/Blorp6.png");
    
    hideGui = false;
    
    //FONTS
	//ofTrueTypeFont::setGlobalDpi(72);
    
	codePro.load("fonts/TJ-Evolette-A-Light.otf", 35, true, true);
	codePro.setLineHeight(35.0f);
	codePro.setLetterSpacing(1.037);
    codeProLight.load("fonts/CodeProLightLC.otf", 35, true, true);
	codeProLight.setLineHeight(35.0f);
	codeProLight.setLetterSpacing(1.037);
    
    //FBO Stuff
    ofFbo::Settings settings;    
    settings.width = 1024;    
    settings.height = 1024;    
    settings.internalformat = GL_RGBA;    
    //settings.numSamples = 0;
    //settings.useDepth = false;
    //settings.useStencil = false;
    
    fboNew.allocate(1024,1024,GL_RGB);
    
    //App variable setting
    counter = 1;
    
    backSwitch = true;
    
    lineThick = 0.1;
    
    mystery = .2;
    
    snapPhoto = false;
    flashCounter = 0;
    
    modeChange= false;
    //Init first mode
    CurrentModeString = "Swipe for different modes";
    mysterySwitch = true;
    addBlend = false;
    backSwitch = true;
    BWSwitch = false;
    motionDetect = false;
    blurAmt = .5;
    lineThick = .2;
    threshold = 127;
    mystery = .13;
    mystery2= .9;

    
    initMotion();
    motionDetect = false;
    
    threshold = 120;
    exposure = 80;
    camState = 1; //Switch to front camera first
    
    addBlend = false;  
    
    loc.x = 0;
    loc.y = ofGetHeight()/2;
    timer = ofGetElapsedTimeMillis();
    
    //Make sure device can even support flashlight
   
    flash=false;
 
    shufflin = false;
    
    //ofEnableAlphaBlending();
    ofBackground(0, 0, 0);
    
    loadFade = 255;
    CurrentModeString = "Swipe for different modes!";
    updateGUIvalues();
 
    initialLoad = true;
}

void ofApp :: initMotion()
{
	cameraGrayPrevImage.allocate( camWidth, camHeight );
	cameraGrayDiffImage.allocate( camWidth, camHeight );
	cameraDiffFloatImage.allocate( camWidth, camHeight );
	cameraMotionFloatImage.allocate( camWidth, camHeight );
    camMotionGray.allocate(camWidth, camHeight);
	cameraMotionFadeAmount = 0.85f;
} 

//--------------------------------------------------------------
void ofApp::update(){
 
    
    //Call to function to rotate the views - FIX GLITCH WHEN NEW ROTATION HAPPENS
    changeOrientation([UIDevice currentDevice].orientation);
    //Change front or back camera
    if(switchCam==true){
        switchCamera();
    }
    
    camWidth = vidGrabber.getWidth();
    camHeight= vidGrabber.getHeight();

    bool bNewFrame = false;
    
    vidGrabber.update();
    bNewFrame = vidGrabber.isFrameNew();
   
    if (motionDetect) {
        //Enable Motion detection for contour drawing
        if (bNewFrame){
            colorImg.setFromPixels(vidGrabber.getPixels(), camWidth,camHeight); 
            cameraGrayPrevImage	= grayImg;
            grayImg=colorImg;
            //Only transfer into extra image if necessary
            if(BWSwitch){
                blackwhiteImage=colorImg;
            }
            cameraGrayDiffImage.absDiff( grayImg, cameraGrayPrevImage );
            cameraGrayDiffImage.threshold( threshold );
            cameraDiffFloatImage	= cameraGrayDiffImage;
            cameraMotionFloatImage	*= cameraMotionFadeAmount;
            cameraMotionFloatImage	+= cameraDiffFloatImage;
            cameraMotionFloatImage.blur( 3 );
            camMotionGray = cameraMotionFloatImage.getPixels(); //Turn it back into char
            
            contourFinder.findContours(camMotionGray, 20, (camWidth*camHeight)/3, 10, true);

        }
    }  
    
    else { 
        //Normal motion detection
        if (bNewFrame){
            colorImg.setFromPixels(vidGrabber.getPixels(), camWidth,camHeight);
            grayImg=colorImg;
            //Only transfer into extra image if necessary
            if(BWSwitch){
                blackwhiteImage=colorImg;
            }
            grayImg.threshold(threshold);
            contourFinder.findContours(grayImg, 20, (camWidth*camHeight)/3, 10, true);
            colorHold.setFromPixels(vidGrabber.getPixels(), camWidth, camHeight, OF_IMAGE_COLOR);
        }
    } 
    
    //Color Cycling
    //if (hCycle < 255) hCycle += 0.5;
	//else hCycle = 0;
	
	//color.setHue(hCycle);
	//color.setHsb(hCycle, 255, 255);
    color.setHue(threshold);
	color.setHsb(threshold, 255, 255);
    
    ModColor.setHue(blurAmt);
    ModColor.setHsb(blurAmt,255,255);
    

    
}

//--------------------------------------------------------------
void ofApp::draw(){	

    ofBackground(0,0,0);
    if(initialLoad){
        initialLoad = false;
    fboNew.begin();
    ofClear(0, 0, 0, 0);
    fboNew.end();
    }
    
    giganticDraw();
    
    
    //ofSetColor(255, 0, 0);
    //ofDrawRectangle(500*sin(ofGetElapsedTimef()),200*sin(0.7*ofGetElapsedTimef()),400,400);
    
    //ofDrawBitmapStringHighlight("Width: " + ofToString(ofGetWidth()) + " Height: " + ofToString(ofGetHeight()), 200,200);
    //cout<<ofGetWidth()<<endl;
    //cout<<ofGetHeight()<<endl;
}

void ofApp::giganticDraw(){
    
    //Holy shit - this function is godawful - shame on me in 2012 - this needs to be broken out to so many classes and functions
    
    if (addBlend) {
        //Additive blending
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
    }
    
    ofPushMatrix(); //For proper rotation
    
    ofSetColor(255);
    
    
    if (camState==0) { ///FRONT CAMERAAAAAA
        camWidth = vidGrabber.getWidth();
        if ([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeLeft) {
            /*
            camDeform.x=0;
            camDeform.y=100;
            camWidth = vidGrabber.getWidth()-0;
            camHeight = vidGrabber.getHeight()-50;
            ofRotateY(180);
            ofRotateZ(-180);
            ofTranslate(0, -640);
             */
            camDeform = ofPoint(0,0);
            camWidth = vidGrabber.getWidth();
            camHeight = vidGrabber.getHeight();
            ofRotateY(180);
            ofRotateZ(-180);
            ofTranslate(0,-640);
        }
        
        else if ([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeRight) {
            camDeform.x=0;
            camDeform.y=100;
            camWidth = vidGrabber.getWidth()-0;
            camHeight = vidGrabber.getHeight()-50;
            ofRotateY(180);
            ofRotateZ(180);
            ofTranslate(0, -640);
        }
        else if ([UIDevice currentDevice].orientation==UIDeviceOrientationPortrait) {
            camDeform.x=0;
            camDeform.y=100;
            camWidth = vidGrabber.getWidth()-0;
            camHeight = vidGrabber.getHeight()-50;
            ofRotateY(0);
            ofRotateZ(0);
            ofRotateX(180);
            ofTranslate(0, -640);
        }
        
    }
    else {
        //Reset for back camera
        camDeform.x = 0;
        camDeform.y = 0;
        camWidth = vidGrabber.getWidth();
        camHeight = vidGrabber.getHeight();
    }
    
    
    
    //General line width setting...may be deprecated
    ofSetLineWidth(ofMap(lineThick, 0.0,1.0,0.0,10.0));
    //Draw video background
    if(backSwitch){
        if (!BWSwitch) {
            vidGrabber.draw(0,0, vidGrabber.getWidth()*2,vidGrabber.getHeight()*2);
        }
        else {
            blackwhiteImage.draw(0,0, vidGrabber.getWidth()*2,vidGrabber.getHeight()*2);
        }
    }
    
    
    //=============Presets============
    //Presets for each mode...check here if something is misbehaving
    if (modeChange){
        //Bubble
        if (counter==1) {
            CurrentModeString = "         Bubble Eye";
            mysterySwitch = true;
            addBlend = false;
            backSwitch = true;
            BWSwitch = false;
            motionDetect = false;
            blurAmt = .5;
            lineThick = .2;
            threshold = 127;
            mystery = .1;
            mystery2= .9;
            updateGUIvalues();
        }
        
        //Triangle
        if (counter==2) {
            CurrentModeString = "        Crystal Eye";
            mysterySwitch = false;
            addBlend = false;
            backSwitch = true;
            BWSwitch = false;
            motionDetect = false;
            blurAmt = .5;
            lineThick = .5;
            threshold = 127;
            mystery = .1;
            mystery2=.5;
            updateGUIvalues();
        }
        
        //Dino
        if (counter==3) {
            CurrentModeString = "      Spiky Eye";
            mysterySwitch = true;
            addBlend = false;
            backSwitch = true;
            BWSwitch = false;
            motionDetect = false;
            blurAmt = .5;
            lineThick = .5;
            threshold = 127;
            mystery = .5;
            mystery2=.5;
            updateGUIvalues();
        }
        
        //Standard
        if (counter==4) {
            CurrentModeString = "          Line Eye";
            mysterySwitch = true;
            addBlend = false;
            backSwitch = true;
            BWSwitch = false;
            motionDetect = false;
            blurAmt = .3;
            lineThick = .1;
            threshold = 127;
            mystery = .2;
            mystery2=0;
            updateGUIvalues();
        }
        
        //KlimtMode
        if (counter==5) {
            CurrentModeString = "         Klimt Eye";
            mysterySwitch = false;
            addBlend = false;
            backSwitch = true;
            BWSwitch = false;
            motionDetect = false;
            blurAmt = .5;
            lineThick = .5;
            threshold = 127;
            mystery = .1;
            mystery2=.35;
            updateGUIvalues();
        }
        
        if (counter==6) {
            CurrentModeString = "         Bubble Bath";
            mysterySwitch = false;
            addBlend = false;
            backSwitch = true;
            BWSwitch = false;
            motionDetect = false;
            blurAmt = .5;
            lineThick = .5;
            threshold = 127;
            mystery = .1;
            mystery2=.35;
            updateGUIvalues();
        }
        
        //Make sure this gets reset so that it doesn't make values stick
        modeChange=false;
    }
    
    
    if(snapSpecial){
        fboNew.begin();
    }
    
    ofPoint mapResolution = ofPoint(camWidth*2, camHeight*2);
    //========BUBBLES=========
    if (counter ==1) {
        
        
        MysteryConnect = ofMap(mystery, 0.0, 1.0, 10, 60);
        MysteryConnect2 = ofMap(mystery2, 0.0, 1.0, 3, 15);
        ofSetCircleResolution(MysteryConnect2);
        
        for( int i=0; i<(int)contourFinder.blobs.size(); i++ ) {
            
            ofBeginShape();
            for( int k=0; k<contourFinder.blobs[i].nPts; k+=5){
                mapPt.x=ofMap(contourFinder.blobs[i].pts[k].x,0,camWidth,0,mapResolution.x);
                mapPt.y=ofMap(contourFinder.blobs[i].pts[k].y,0,camHeight,0,mapResolution.y);
                ofVertex( mapPt.x, mapPt.y );
                mapCent.x = ofMap(contourFinder.blobs[i].centroid.x,0,camWidth,0,mapResolution.x);
                mapCent.y = ofMap(contourFinder.blobs[i].centroid.y,0,camHeight,0,mapResolution.y);
                
                //ofSetColor(255, 255, 255);
                //ofVertex(mapPt.x, mapPt.y);
                //ofLine(mapPt.x,mapPt.y,mapCent.x,mapCent.y);
                //ofSetColor(color);
                
                ofFloatColor colorBig;
                colorBig.set(colorHold.getColor(contourFinder.blobs[i].pts[k].x, contourFinder.blobs[i].pts[k].y));
                ofSetColor(colorBig);
                
                // ofCircle(mapPt.x, mapPt.y, ofRandom(5,18));
                ofFill();
                ofDrawCircle(mapPt.x, mapPt.y, ofRandom(5,MysteryConnect));
                if (!mysterySwitch) {
                    ofFill();
                }
                else {
                    ofNoFill();
                }
                
                //ofCircle(mapCent.x, mapCent.y, 10);
                //ofSetColor(255, 255, 255,200);
            }
            ofEndShape();
        }
        
    }
    
    //=========Spiked triangles=========
    if(counter==2){
        
        for( int i=0; i<(int)contourFinder.blobs.size(); i++ ) {
            ofFill();
            //ofBeginShape();
            for( int j=0; j<contourFinder.blobs[i].nPts; j=j+ofMap(mystery, 0, 1, 1, 20) ) {
                mapPt.x=ofMap(contourFinder.blobs[i].pts[j].x,0,camWidth,0,mapResolution.x);
                mapPt.y=ofMap(contourFinder.blobs[i].pts[j].y,0,camHeight,0,mapResolution.y);
                
                nextMappedPt.x = ofMap(contourFinder.blobs[i].pts[ofClamp(j+10,0,contourFinder.blobs[i].nPts-10) ].x,0,camWidth,0,mapResolution.x);
                nextMappedPt.y = ofMap(contourFinder.blobs[i].pts[ofClamp(j+10,0,contourFinder.blobs[i].nPts-10) ].y,0,camHeight,0,mapResolution.y);
                
                mapCent.x = ofMap(contourFinder.blobs[i].centroid.x,0,camWidth,0,mapResolution.x);
                mapCent.y = ofMap(contourFinder.blobs[i].centroid.y,0,camHeight,0,mapResolution.y);
                
                /*
                 ofSetColor(ofMap(j, 0, contourFinder.blobs[i].nPts, 0, 255),
                 ofMap(j, 0, contourFinder.blobs[i].nPts, 60, 255),
                 ofMap(j, 0, contourFinder.blobs[i].nPts, 127, 255));
                 */
                ofFloatColor color1;
                color1=colorHold.getColor(contourFinder.blobs[i].pts[j].x,contourFinder.blobs[i].pts[j].y);
                ofSetColor(color1);
                ofDrawTriangle(mapPt.x, mapPt.y, nextMappedPt.x, nextMappedPt.y, mapCent.x, mapCent.y);
                
                /* EXPERIMENTAL, REQUIRES LOTS OF OF CORE MODIFICATIONS
                 ofFloatColor color1;
                 color1=colorHold.getColor(contourFinder.blobs[i].pts[j].x,contourFinder.blobs[i].pts[j].y);
                 ofFloatColor color2;
                 color2=colorHold.getColor(contourFinder.blobs[i].centroid.x,contourFinder.blobs[i].centroid.y);
                 ofFloatColor color3;
                 color3=colorHold.getColor(contourFinder.blobs[i].pts[ofClamp(j+10,0,contourFinder.blobs[i].nPts-10) ].x,contourFinder.blobs[i].pts[ofClamp(j+10,0,contourFinder.blobs[i].nPts-10) ].y);
                 
                 ofColorTriangle(mapPt.x, mapPt.y, 0.0, mapCent.x, mapCent.y, 0.0, nextMappedPt.x, nextMappedPt.y, 0.0, color1, color2, color3);
                 */
            }
            //ofSetColor(255,255,255);
        }
    }
    
    //==========Dinosaur mode===========
    if(counter == 3){
        
        
        if(mysterySwitch){
            MysteryConnect = ofMap(mystery, 0.0, 1.0, 5, 60);
            MysteryConnect2 = ofMap(mystery2, 0.0, 1.0, 10, 30);
            int scale = MysteryConnect;
            int stepSize = MysteryConnect2;
            for( int i = 0; i < (int)contourFinder.blobs.size(); i++ ) {
                ofMesh mesh;
                for( int j = 0; j < contourFinder.blobs[i].nPts - stepSize; j += stepSize ) {
                    a = contourFinder.blobs[i].pts[j];
                    b = contourFinder.blobs[i].pts[j + stepSize];
                    mappedA.x = ofMap(a.x, 0, camWidth, 0, mapResolution.x);
                    mappedA.y = ofMap(a.y, 0, camHeight, 0, mapResolution.y);
                    mappedB.x = ofMap(b.x, 0, camWidth, 0, mapResolution.x);
                    mappedB.y = ofMap(b.y, 0, camHeight, 0, mapResolution.y);
                    tangent = mappedB - mappedA;
                    normal = tangent.getRotated(90);
                    normal.normalize();
                    ofVec2f corner = (mappedA + mappedB) / 2 + normal * scale;
                    // FOR STRAIGHT SECTIONS
                    mesh.addVertex(mappedA);
                    mesh.addVertex(mappedB);
                    mesh.addVertex(corner);
                    color.set(colorHold.getColor(contourFinder.blobs[i].pts[j].x, contourFinder.blobs[i].pts[j].y));
                }
                ofSetColor(color);
                mesh.draw();
            }
        }
        
        if(!mysterySwitch){
            MysteryConnect = ofMap(mystery, 0.0, 1.0, 5, 60);
            MysteryConnect2 = ofMap(mystery2, 0.0, 1.0, 12, 30);
            
            int scale = MysteryConnect;
            int stepSize = MysteryConnect2;
            for( int i = 0; i < (int)contourFinder.blobs.size(); i++ ) {
                ofBeginShape();
                for( int j = 0; j < contourFinder.blobs[i].nPts - stepSize; j += stepSize ) {
                    a = contourFinder.blobs[i].pts[j];
                    b = contourFinder.blobs[i].pts[j + stepSize];
                    mappedA.x = ofMap(a.x, 0, camWidth, 0, mapResolution.x);
                    mappedA.y = ofMap(a.y, 0, camHeight, 0, mapResolution.y);
                    mappedB.x = ofMap(b.x, 0, camWidth, 0, mapResolution.x);
                    mappedB.y = ofMap(b.y, 0, camHeight, 0, mapResolution.y);
                    tangent = mappedB - mappedA;
                    normal = tangent.getRotated(90);
                    normal.normalize();
                    float noisy = ofMap(ofNoise(j,j,ofGetElapsedTimef()/2.0),0,1,0,scale);
                    ofVec2f corner = (mappedA + mappedB) / 2 + normal * noisy;
                    ofCurveVertex(mappedA.x, mappedA.y);
                    ofCurveVertex(corner.x, corner.y);
                    ofCurveVertex(mappedB.x, mappedB.y);
                    color.set(colorHold.getColor(contourFinder.blobs[i].pts[j].x, contourFinder.blobs[i].pts[j].y));
                }
                ofSetColor(color);
                ofEndShape();
            }
        }
        
    }
    
    //========Regular drawing=========
    if(counter==4){
        
        for(int i=0; i<(int)contourFinder.blobs.size(); i++ ) {
            //ofSetColor(color);
            ofNoFill();
            ofBeginShape();
            for( int j=0; j<contourFinder.blobs[i].nPts; j=j+ofMap(mystery, 0, 1, 1, 20) ) {
                mapPt.x=ofMap(contourFinder.blobs[i].pts[j].x,0,camWidth,0,mapResolution.x);
                mapPt.y=ofMap(contourFinder.blobs[i].pts[j].y,0,camHeight,0,mapResolution.y);
                ofVertex(mapPt);
                
                //Draw connections to center - OPTIONAL
                //ofSetLineWidth(ofMap(connectDist [i][j], 0, 300, .1, 7));
                if(mysterySwitch){
                    mapCent.x = ofMap(contourFinder.blobs[i].centroid.x,0,camWidth,0,mapResolution.x);
                    mapCent.y = ofMap(contourFinder.blobs[i].centroid.y,0,camHeight,0,mapResolution.y);
                    int centDist;
                    centDist = ofDist(mapPt.x,mapPt.y, mapCent.x,mapCent.y);
                    ofSetLineWidth(ofMap(centDist, 0, 400, .03, 2.5));
                    color.set(colorHold.getColor(contourFinder.blobs[i].pts[j].x, contourFinder.blobs[i].pts[j].y));
                    ofSetColor(color);
                    ofDrawLine(mapPt.x,
                           mapPt.y,
                           mapCent.x,
                           mapCent.y
                           );
                }
            }
            
            //ExtraSketches
            if (mystery2>0) {
                ofSetLineWidth(ofMap(lineThick, 0.0, 1.0, 0.0, 3.0));
                for (int k = 1; k<ofMap(mystery2, 0.0, 1.0, 1, 30); k++) {
                    //color.setHsb(i*k*7, 255, 255);
                    ofSetColor(color);
                    for( int j=0; j<contourFinder.blobs[i].nPts; j+=k*4 ) {
                        mapPt.x=ofMap(contourFinder.blobs[i].pts[j].x,0,camWidth,0,mapResolution.x);
                        mapPt.y=ofMap(contourFinder.blobs[i].pts[j].y,0,camHeight,0,mapResolution.y);
                        ofVertex( mapPt.x, mapPt.y );
                    }
                }
            }
            ofSetLineWidth(ofMap(lineThick, 0.0, 1.0, 0.0, 10.0));
            ofEndShape();
        }
        
    }
    
    //KlimtMode==============
    if (counter==5) {
        
        for( int i=0; i<(int)contourFinder.blobs.size(); i++ ) {
            for( int j=0; j<contourFinder.blobs[i].nPts; j=j+ofMap(mystery, 0, 1, 1, 80)){
                ofSetColor(colorHold.getColor(contourFinder.blobs[i].pts[j].x, contourFinder.blobs[i].pts[j].y)) ;
                mapPt.x=ofMap(contourFinder.blobs[i].pts[j].x,0,camWidth,0,mapResolution.x);
                mapPt.y=ofMap(contourFinder.blobs[i].pts[j].y,0,camHeight,0,mapResolution.y);
                if (!mysterySwitch) {
                    ofFill();
                    int randomRectX= ofRandom(1,ofMap(mystery2, 0, 1, 1, 80));
                    
                    //int randomRectY= ofRandom(1,ofMap(mystery2, 0, 1, 1, 80));
                    ofDrawRectangle(mapPt, randomRectX,randomRectX);
                    ofNoFill();
                    ofSetLineWidth(.5);
                    ofSetColor(0, 0, 0);
                    ofDrawRectangle(mapPt, randomRectX,randomRectX);
                }
                else {
                    ofFill();
                    int randomRectX= ofRandom(1,ofMap(mystery2, 0, 1, 1, 80));
                    gradSquare.draw(mapPt, randomRectX,randomRectX);
                    ofNoFill();
                    ofSetLineWidth(.5);
                    ofSetColor(0, 0, 0);
                    ofDrawRectangle(mapPt, randomRectX,randomRectX);
                }
                
            }
        }
    }
    //3d Spheremode==============
    if (counter==6) {
        
        for( int i=0; i<(int)contourFinder.blobs.size(); i++ ) {
            for( int j=0; j<contourFinder.blobs[i].nPts; j=j+ofMap(mystery, 0, 1, 1, 80)){
                ofSetColor(colorHold.getColor(contourFinder.blobs[i].pts[j].x, contourFinder.blobs[i].pts[j].y)) ;
                mapPt.x=ofMap(contourFinder.blobs[i].pts[j].x,0,camWidth,0,mapResolution.x);
                mapPt.y=ofMap(contourFinder.blobs[i].pts[j].y,0,camHeight,0,mapResolution.y);
                
                
                int randomRectX= ofRandom(1,ofMap(mystery2, 0, 1, 1, 80));
                
                //int randomRectY= ofRandom(1,ofMap(mystery2, 0, 1, 1, 80));
                sphere_oid.draw(mapPt, randomRectX,randomRectX);
            }
        }
    }
    
    
    /*
     EASTER EGG MODES?
     //Color blobs
     if(counter==5){
     for( int i=0; i<(int)contourFinder.blobs.size(); i++ ) {
     ofNoFill();
     ofSetLineWidth(lineThick);
     ofBeginShape();
     for( int j=0; j<contourFinder.blobs[i].nPts; j++ ) {
     mapPt.x=ofMap(contourFinder.blobs[i].pts[j].x,0,camWidth,0,ofGetWidth());
     mapPt.y=ofMap(contourFinder.blobs[i].pts[j].y,0,camHeight,0,ofGetHeight());
     ofVertex( mapPt.x, mapPt.y );
     }
     ofEndShape();
     
     
     //Mystery decides how many extra divisions between sketchy lines
     for (int k = 1; k<ofMap(mystery, 0.0, 1.0, 1, 30); k++) {
     color.setHsb(i*k*5, 255, 255);
     ofSetColor(color);
     
     ofBeginShape();
     ofSetLineWidth(lineThick*k*4);
     
     for( int j=0; j<contourFinder.blobs[i].nPts; j+=k*4 ) {
     mapPt.x=ofMap(contourFinder.blobs[i].pts[j].x,0,camWidth,0,ofGetWidth());
     mapPt.y=ofMap(contourFinder.blobs[i].pts[j].y,0,camHeight,0,ofGetHeight());
     ofVertex( mapPt.x, mapPt.y );
     
     }
     ofEndShape();
     }
     
     }
     ofSetColor(255,255,255);
     
     }
     
     //Connected centroids
     if(counter==6){
     MysteryConnect = ofMap(mystery, 0.0, 1.0, 50, 300);
     for(int i=0; i<(int)contourFinder.blobs.size(); i++ ) {
     for (int j=0; j<(int)contourFinder.blobs.size(); j++ ) {
     connectDist[i][j] = ofDist(ofMap(contourFinder.blobs[i].centroid.x,0, camWidth,0,ofGetWidth()),
     ofMap(contourFinder.blobs[i].centroid.y,0,camHeight,0,ofGetHeight()),
     ofMap(contourFinder.blobs[j].centroid.x,0, camWidth,0,ofGetWidth()),
     ofMap(contourFinder.blobs[j].centroid.y,0,camHeight,0,ofGetHeight()));
     blobConnect[i]=0;
     }
     }
     for( int i=0; i<(int)contourFinder.blobs.size(); i++ ) {
     ofSetColor(ModColor,127);
     mapCent.x = ofMap(contourFinder.blobs[i].centroid.x,0,camWidth,0,ofGetWidth());
     mapCent.y = ofMap(contourFinder.blobs[i].centroid.y,0,camHeight,0,ofGetHeight());
     
     for (int j=0; j<(int)contourFinder.blobs.size(); j++ ){
     //Only draw lines if the distance between points is within that range
     
     if (connectDist [i][j] < MysteryConnect) {
     //ofMap(sin(ofGetElapsedTimef()), -1, 1, 50, 400)
     
     ofSetLineWidth(ofMap(connectDist[i][j], 0, MysteryConnect, .1, 6));
     blobConnect[i]++;
     ofSetColor(255,255,255, 160);
     ofLine(ofMap(contourFinder.blobs[j].centroid.x,0, camWidth,0,ofGetWidth()),
     ofMap(contourFinder.blobs[j].centroid.y,0,camHeight,0,ofGetHeight()),
     ofMap(contourFinder.blobs[i].centroid.x,0, camWidth,0,ofGetWidth()),
     ofMap(contourFinder.blobs[i].centroid.y,0,camHeight,0,ofGetHeight()));
     
     ofSetColor(ModColor, 200);
     
     ofFill();
     
     ofCircle(mapCent.x, mapCent.y, ofMap(blobConnect[i], 0, 10, 2, 20));
     
     //ofDrawBitmapString(ofToString(connectDist [i][j]), mapCent.x,mapCent.y);
     
     }
     }
     }
     
     }*/
    
    
    if (addBlend) {
        glDisable(GL_BLEND);
    }
    ofPopMatrix();
    
    //STOP ROTATION
    
    //Experimental thresholder images
    //Make this a variable value
    if (snapSpecial && threshCounter < exposure+1) {
        fboNew.end();
        
        ofSetColor(255, 255, 255);
        //if([UIDevice currentDevice].orientation==3 || [UIDevice currentDevice].orientation==0){
        ofPushMatrix();
        if(camState==0){ //If front camera
            ofRotateY(180);
            ofRotateZ(-180);
            ofTranslate(0,-640);
        }
        if(camState==0 && [UIDevice currentDevice].orientation==UIDeviceOrientationPortrait){ //If front camera
            // ofRotateY(180);
            ofRotateX(0);
            ofTranslate(0,0); //DONE FIXED>>LEAVE IT!
        }
        ofPushMatrix();
        //ofRotateZ(90);
        //ofTranslate(0, -1024);
        ofSetColor(255, 255, 255);
        fboNew.draw(0, 0);
        ofPopMatrix();
        ofPopMatrix();
        //}
        
        /*
         if([UIDevice currentDevice].orientation==4 || [UIDevice currentDevice].orientation==0){
         ofPushMatrix();
         ofRotateZ(-90);
         ofTranslate(-1024, 0);
         ofSetColor(255, 255, 255);
         fboNew.draw(0, 0);
         ofPopMatrix();
         }
         /*/
        threshold = ofMap(threshCounter, 0, exposure, 0, 255);
        //Currently this is not actually getting every thresh level because its happening twice per frame
        if (threshCounter==exposure) {
            ofxiPhoneAppDelegate * delegate = ofxiPhoneGetAppDelegate();
            ofxiPhoneScreenGrab(delegate);
            snapSpecial = false;
            fboNew.begin();
            ofClear(0, 0, 0, 0);
            fboNew.end();
            threshold = 120;
            flashCounter = 255;
            fadetimeSave = ofGetElapsedTimef();
        }
        threshCounter++;
        
    }
    else {
        threshCounter = 0;
        
    }
    
    
    
    
    //TAKE A PICTURE
    if (snapPhoto) {
        snapPhoto = false;
        ofxiPhoneAppDelegate * delegate = ofxiPhoneGetAppDelegate();
        ofxiPhoneScreenGrab(delegate);
        flashCounter = 255;
        fadetimeSave = ofGetElapsedTimef();
    }
    
    if(flashCounter>0 ){
        //Screen FLASH
        flashCounter = ofClamp(ofMap(ofGetElapsedTimef(), fadetimeSave, fadetimeSave+3, 280,0),0,280);
        ofSetColor(255, 255, 255,flashCounter);
        ofFill();
        ofDrawRectangle(0, 0, ofGetWidth(), ofGetHeight());
        ofNoFill();
        if ([UIDevice currentDevice].orientation == 3 || [UIDevice currentDevice].orientation == 2 ||
            [UIDevice currentDevice].orientation == 5 || [UIDevice currentDevice].orientation == 6 || [UIDevice currentDevice].orientation == 0) {
            ofSetColor(0, 0, 0, flashCounter );
            codePro.drawString("      Photo saved\n\nto your photo album!", 280,310);
        }
        else if ([UIDevice currentDevice].orientation == 4) {
            ofPushMatrix();
            ofRotateZ(-180);
            ofTranslate(-ofGetWidth(), -ofGetHeight());
            ofSetColor(0, 0, 0, flashCounter );
            codePro.drawString("      Photo saved\n\nto your photo album!", 280,310);
            ofPopMatrix();
            
        }
        else if ([UIDevice currentDevice].orientation == 1) {
            ofPushMatrix();
            ofRotateZ(-90);
            ofTranslate(-640, -0);
            ofSetColor(0, 0, 0, flashCounter );
            codePro.drawString("      Photo saved\n\nto your photo album!", 100,350);
            ofPopMatrix();
            
        }
    }
    
    
    
    //---------Anything after this will NOT be captured by the snapshot_taker--------------------
    
    //Camera control interface
    if( [UIDevice currentDevice].orientation == 3 || [UIDevice currentDevice].orientation == 2 ||
       [UIDevice currentDevice].orientation == 5 || [UIDevice currentDevice].orientation == 6 || [UIDevice currentDevice].orientation == 0)
    { //if either landscape, face down, face up, or unknow
        if(myGuiViewController.view.hidden){
            ofFill();
            ofEnableAlphaBlending();
            ofSetColor(255, 255, 255,255);
            fullGui.draw(0,0,960,640);
            
            //camswitchIcon.draw(35,-15,150,150);
            ofSetColor(255, 255, 255);
            codePro.drawString(CurrentModeString, 240,600);
            if (snapSpecial) {
                ofFill();
                ofSetColor(255, 255, 255,90);
                ofDrawRectangle(240, 500, 520, 38);
                ofSetColor(255, 255, 255,127);
                ofDrawRectangle(ofMap(threshold, 0, 255, 480, 240), 500, ofMap(threshold, 0, 255, 0, 520), 38);
                ofSetColor(0, 0, 0);
                
                if (threshold<245) {
                    codePro.drawString("Hold still...Processing...", 260,530);
                }
                
                else {
                    codePro.drawString("DONE! - Photo saved!", 285,530);
                }
            }
        }
        //cout << "Landscape case"<<endl;
    }
    else if( [UIDevice currentDevice].orientation == 4 ) {
        if(myGuiViewController.view.hidden){
            ofPushMatrix();
            ofRotateZ(-180);
            ofTranslate(-ofGetWidth(), -ofGetHeight());
            ofFill();
            ofEnableAlphaBlending();
            ofSetColor(255, 255, 255,255);
            
            fullGui.draw(0,0,960,640);
            
            ofSetColor(255, 255, 255,100);
            //camswitchIcon.draw(35,-15,150,150);
            ofSetColor(255, 255, 255);
            codePro.drawString(CurrentModeString, 240,600);
            if (snapSpecial) {
                ofFill();
                ofSetColor(255, 255, 255,90);
                ofDrawRectangle(240, 500, 520, 38);
                ofSetColor(255, 255, 255,127);
                ofDrawRectangle(ofMap(threshold, 0, 255, 480, 240), 500, ofMap(threshold, 0, 255, 0, 520), 38);
                ofSetColor(0, 0, 0);
                
                if (threshold<245) {
                    codePro.drawString("Hold still...Processing...", 260,530);
                }
                
                else {
                    codePro.drawString("DONE! - Photo saved!", 285,530);
                }
            }
            ofPopMatrix();
            
        }
        //cout << "Landscape case"<<endl;
    }
    
    //Portrait
    else if([UIDevice currentDevice].orientation == 1){
        if(myGuiViewController.view.hidden){
            ofPushMatrix();
            ofRotateZ(-90);
            ofTranslate(-640, -0);
            ofFill();
            ofEnableAlphaBlending();
            
            ofSetColor(255, 255, 255,255);
            
            codePro.drawString(CurrentModeString, 60,775);
            if (snapSpecial) {
                ofFill();
                ofSetColor(255, 255, 255,90);
                ofDrawRectangle(60, 700, 505, 38);
                ofSetColor(255, 255, 255,127);
                ofDrawRectangle(ofMap(threshold, 0, 255, 320, 60), 700, ofMap(threshold, 0, 255, 0, 520), 38);
                ofSetColor(0, 0, 0);
                
                if (threshold<245) {
                    codePro.drawString("Hold still...Processing...", 80,730);
                }
                
                else {
                    codePro.drawString("DONE! - Photo saved!", 80,730);
                }
            }
            ofPopMatrix();
            ofSetColor(255, 255, 255,255);
            fullGuiPortrait.draw(0,0,960,640);
            //cout << "Portrait case"<<endl;
        }
        
    }
    
    //RANDO-MIZER
    if(shufflin){
        CurrentModeString = "        RANDOM EYE";
        counter = (int) ofRandom(1,7);
        mysterySwitch = (int) ofRandom(0,50)%2;
        //addBlend = (int) ofRandom(0,50)%2;
        //backSwitch = (int) ofRandom(0,1);
        BWSwitch = (int) ofRandom(0,50)%2;
        //motionDetect = false; //Too confusing to randomize IMHO
        blurAmt = ofRandom(0,1);
        lineThick = ofRandom(0,1);
        threshold = (int) ofRandom(0,255);
        mystery = ofRandom(0,1);
        mystery2= ofRandom(0,1);
        shufflin = false;
        updateGUIvalues();
        
    }
    
    if(loadFade>0){
        ofSetColor(255,255,255,loadFade);
        loadScreen.draw(0,0,ofGetWidth(),ofGetHeight());
        loadFade=loadFade-7;
    }
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs &touch){
    
    if([UIDevice currentDevice].orientation == 0 ||
       [UIDevice currentDevice].orientation == 1 ||
       [UIDevice currentDevice].orientation == 2 ||
       [UIDevice currentDevice].orientation == 3 ||
       [UIDevice currentDevice].orientation == 5 ||
       [UIDevice currentDevice].orientation == 6)
        {
            
            if (touch.x>800 && touch.x<960 && touch.y>250 && touch.y<400){
                snapPhoto = true;
            }
            
            if (touch.x>812 && touch.x<922 && touch.y>450 && touch.y<610){
                snapSpecial  = true;
            }
            
            if (touch.x>0 && touch.x<150 && touch.y>0 && touch.y<160){
                //switchCamera();
            }
            /*if (touch.x>0 && touch.x<150 && touch.y>350 && touch.y<640){
                if (flash) {
                    flash=false;
                }
                else{
                flash=true;
                }
            }*/
            
            if (touch.x>810 && touch.x<920 && touch.y>20 && touch.y<200){
                if( myGuiViewController.view.hidden ){
                    myGuiViewController.view.hidden = NO;
                }
            }
    }
    else {
            if (touch.x>25 && touch.x<200 && touch.y>250 && touch.y<400){
                snapPhoto = true;
            }
            if (touch.x>25 && touch.x<250 && touch.y>20 && touch.y<170){
                snapSpecial = true;   
            }
            
            if (touch.x>800 && touch.x<900 && touch.y>500 && touch.y<640){
                switchCamera(); //Currently dropped from functionality
            }
            
            if (touch.x>25 && touch.x<250 && touch.y>500 && touch.y<640){
                if( myGuiViewController.view.hidden ){
                    myGuiViewController.view.hidden = NO;
                }
            }
    }
    
    /*
    else if([UIDevice currentDevice].orientation == 0 || [UIDevice currentDevice].orientation == 2 || 
       [UIDevice currentDevice].orientation == 3 || [UIDevice currentDevice].orientation == 4 ||
       [UIDevice currentDevice].orientation == 5 || [UIDevice currentDevice].orientation == 6)
    {
        if (touch.x>800 && touch.x<960 && touch.y>250 && touch.y<400){
            snapPhoto = true;
        }
        if (touch.x>812 && touch.x<922 && touch.y>500 && touch.y<610){
            snapSpecial = true;
        }
        
        if (touch.x>0 && touch.x<150 && touch.y>0 && touch.y<160){
            switchCamera();
        }
        
        if (touch.x>810 && touch.x<920 && touch.y>20 && touch.y<120){
            if( myGuiViewController.view.hidden ){
                myGuiViewController.view.hidden = NO;
            }
        }
    }
    
    //For orientation change
    else if  ([UIDevice currentDevice].orientation == 1) {
        if (touch.x>250 && touch.x<400 && touch.y>800 && touch.y<960){
            snapPhoto = true;
        }
        if (touch.x>20 && touch.x<120 && touch.y>800 && touch.y<920){
            snapSpecial = true;
        }
        
        if (touch.x>0 && touch.x<150 && touch.y>0 && touch.y<160){
            switchCamera();
        }
        
        if (touch.x>500 && touch.x<610 && touch.y>812 && touch.y<920){
            if( myGuiViewController.view.hidden ){
                myGuiViewController.view.hidden = NO;
            }
        }
    }*/
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs &touch){
    //Swipe for loc change
    loc.x = touch.x;
    if(loc.x - compare.x > 0){        
        if((loc.x - compare.x) > 100){
            timer = ofGetElapsedTimeMillis();

            counter++;
            counter = ofWrap(counter,1,7);
            modeChange = true;
        }
    }
    
    compare.x = loc.x;
    
    //cout<< touch<<endl;

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs &touch){
   /* if( myGuiViewController.view.hidden ){
        myGuiViewController.view.hidden = NO;
    } */
    shufflin = true;
}
//--------------------------------------------------------------
void ofApp::changeOrientation(int newOrientation){
    
    //ALL of this shit was breaking the view controller for some reason..doing all rotations with OFTranslates now..
    switch (newOrientation) {

        case 1:
           // ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_PORTRAIT);
            break;
        case 2:
            //ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT); 
            break;
        case 3:
            //ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT);
            break;
        case 4:
            //ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
            break;     
        default:
            //ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT);
            break;
    }
    
}
//--------------------------------------------------------------
void ofApp::updateGUIvalues(){
    myGuiViewController.GUIbackground.on = backSwitch;
    myGuiViewController.GUIblackwhite.on = BWSwitch;
    myGuiViewController.GUImysterySw.on = mysterySwitch;
    myGuiViewController.GUImotion.on = motionDetect;
    myGuiViewController.GUIblend.on = addBlend;
    myGuiViewController.GUIthresh.value = threshold/255;
    myGuiViewController.GUIthickness.value = lineThick/10;
    myGuiViewController.GUImystery.value = mystery;
    myGuiViewController.GUImystery2.value = mystery2;
   // myGuiViewController.GUIexposure.value = exposure;
    
}

//--------------------------------------------------------------
void ofApp::switchCamera(){
    
    if (camState==0) {
        vidGrabber.close();
        colorImg.clear();
        grayImg.clear();
        blackwhiteImage.clear();
        
        //Back Camera
        vidGrabber.setDeviceID(0);
        vidGrabber.initGrabber(480,320);
        
        camState = 1;
        camWidth = vidGrabber.getWidth();
        camHeight = vidGrabber.getHeight();
        
        colorImg.allocate(camWidth,camHeight);
        grayImg.allocate(camWidth,camHeight);
        blackwhiteImage.allocate(camWidth, camHeight);

    }
    else if (camState==1) {
        
        //Release grabber
        vidGrabber.close();
        colorImg.clear();
        grayImg.clear();
        blackwhiteImage.clear();
        
        //Front Camera
        vidGrabber.setDeviceID(1);
        vidGrabber.initGrabber(480,320);
        
        camState = 0;
        camWidth = vidGrabber.getWidth();
        camHeight = vidGrabber.getHeight();
        
        colorImg.allocate(camWidth,camHeight);
        grayImg.allocate(camWidth,camHeight);
        blackwhiteImage.allocate(camWidth, camHeight);

    }

}

void ofApp::exit(){
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


