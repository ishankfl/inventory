One or more plugins require a higher Android SDK version.
Fix this issue by adding the following to C:\Users\Dell\Desktop\InventoryMgmtSystem\inventory\android\app\build.gradle:
android {
  compileSdkVersion 34
  ...
}


# second
r (10165): try continueing
I/flutter (10165): Add staff error: HandshakeException: Handshake error in client (OS Error: 
I/flutter (10165):      CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate(handshake.cc:393))


In your main.dart file, add or import the following class:
 import 'dart:io';
 class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
In your main function, add the following line after function definition:
 HttpOverrides.global = MyHttpOverrides();
Your main.dart should look like this

void main() {
 // Your code
 
 HttpOverrides.global = MyHttpOverrides();
  runApp(const ConsultationApp());
}