This project integrates Google's Cloud Print service into Apple's existing AirPrint functionality. For more information, read the [blog post](http://kramerapps.com/blog/post/38090565883/integrate-cloud-print-ios).

# Getting Started

1. Install [Xcode 4.5](https://itunes.apple.com/us/app/xcode/id497799835) which includes the iPhone SDK
2. `git clone git://github.com/conradev/GoogleCloudPrint.git; cd GoogleCloudPrint`
3. `git submodule update --init -—recursive`
4. `export THEOS=$PWD/theos`
5. `mkdir $THEOS/include/Foundation`
6. `cp $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/System/Library/Frameworks/Foundation.framework/Headers/NSXPCConnection.h $THEOS/include/Foundation/`
7. `make`
