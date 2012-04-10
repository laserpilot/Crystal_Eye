#include "testApp.h"
#include "ofMain.h"

int main(){
    ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow;
   // iOSWindow -> enableAntiAliasing(4);
    iOSWindow -> enableRetinaSupport();
	ofSetupOpenGL(iOSWindow,480,320, OF_FULLSCREEN);			// <-------- setup the GL context
	ofRunApp(new testApp);
}
