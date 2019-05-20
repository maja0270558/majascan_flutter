# majascan
**[pub](https://pub.dev/packages/majascan)**

A qr code scanner flutter plugin project.
Using method channel open native camera page scan qr code.

<p align="center">
  <img src="/screenshot_ios.gif">
</p>

## Installation

### 1. Depend on it
Add this to your package's pubspec.yaml file:

```
dependencies:
  majascan: ^0.1.0
```

### 2. Install it
You can install packages from the command line:

with Flutter:
```
$ flutter packages get
```

3. Import it
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

Add Firebase to your project following [this step](https://codelabs.developers.google.com/codelabs/flutter-firebase/#5) (only that step, not the entire guide).

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 21
```

### Example

```dart
String result = "Hey there !";
Future _scanQR() async {
    try {
      String qrResult = await MajaScan.startScan(title: "QRcode scanner");
      setState(() {
        result = qrResult;
      });
    } on PlatformException catch (ex) {
      if (ex.code == MajaScan.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }
```

