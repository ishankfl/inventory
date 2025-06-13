One or more plugins require a higher Android SDK version.
Fix this issue by adding the following to C:\Users\Dell\Desktop\InventoryMgmtSystem\inventory\android\app\build.gradle:
android {
  compileSdkVersion 34
  ...
}