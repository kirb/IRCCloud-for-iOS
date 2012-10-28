# Unofficial IRCCloud iOS App
[GPL licensed.](http://hbang.ws/s/gpl)

## Compilation
Before building in Xcode, checkout the code for UnittWebSocketClient:

    svn co http://unitt.googlecode.com/svn/projects/ unitt-read-only

Now navigate to `unitt-read-only/iOS/UnittWebSocketClient/trunk` and open UnittWebSocketClient.xcodeproj. Press <kbd>⌘B</kbd> to build the project, then drag libUnittWebSocketClient.a from the Products group into the Frameworks group of the IRCCloud project.

## Libraries used
* [UnittWebSocketClient](http://code.google.com/p/unitt)
* [AJNotificationView](https://github.com/ajerez/AJNotificationView)
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD)
