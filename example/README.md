
# majascan  
**[pub link](https://pub.dev/packages/majascan)**  
A QR code scanner flutter plugin project.  
Using method channel open native camera page scan qr code.  
<p align="center">  
  <img src="https://media.giphy.com/media/XB4I4hCGGASWQGCHeu/giphy.gif">  
</p>  

## Installation  
  
### 1. Depend on it  
Add this to your package's pubspec.yaml file:  
```  
dependencies:  
  majascan: ^0.4.0
```  
### 2. Install it  
You can install packages from the command line:  
with Flutter:  
```  
$ flutter packages get  
```  
###3. Import it  
Now in your Dart code, you can use:  
```  
import 'package:majascan/majascan.dart';  
```  
### iOS  
Add the the camera usage description to your Info.plist  
```xml  
<key>NSCameraUsageDescription</key>  
<string>Camera permission is required for qrcode scanning.</string>  
```  
### Android  
For Android, you must do the following before you can use the plugin:  
Add the QrCodeScannerActivity to your AndroidManifest.xml  
      `<activity android:name="com.djgeo.majascan.g_scanner.QrCodeScannerActivity"/>`  
## Example  
 ```dart  
String qrResult = await MajaScan.startScan(
    title: “QRcode scanner”, 
    barColor: Colors.red, 
  	titleColor: Colors.green, 
    qRCornerColor: Colors.blue,
    qRScannerColor: Colors.deepPurple,
	  flashlightEnable: true, 
  	scanAreaScale: 0.7 /// value 0.0 to 1.0
    );
```
 ### Parameters
 **title** : Navigation bar title.
 **barColor** : Navigation bar color.
 **titleColor** : Navigation bar title color (include back icon).
 **qRCornerColor** : Square color.
 **qRScannerColor** : Scanner line color.
 **flashlightEnable** : Flashlight button enable flag.
 **scanAreaScale** : Center scan area size scale.
