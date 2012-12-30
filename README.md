This project integrates Google's Cloud Print service into Apple's existing AirPrint functionality. For more information, read the [blog post](http://kramerapps.com/blog/post/38090565883/integrate-cloud-print-ios).

It uses [AFIncrementalStore](https://github.com/AFNetworking/AFIncrementalStore), [AFOAuth2Client](https://github.com/AFNetworking/AFOAuth2Client) and [AFNetworking](https://github.com/AFNetworking/AFNetworking) to communicate with the Cloud Print API, and [Theos](https://github.com/DHowett/theos) as its build system.

## Getting Started

### Prequisites

- [Xcode 4.5](https://itunes.apple.com/us/app/xcode/id497799835), which includes the iOS 6 SDK
- A jailbroken device running iOS 6

### Building

The first step to build the project is to clone the repository and initialize all of its submodules:

``` sh
git clone git://github.com/conradev/GoogleCloudPrint.git
cd GoogleCloudPrint
git submodule update --init -—recursive
```

Additionally, one header file from the Mountain Lion SDK is required. This is because `NSXPCConnection` is public on OS X, but not iOS.

``` sh
mkdir theos/include/Foundation
cp $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/System/Library/Frameworks/Foundation.framework/Headers/NSXPCConnection.h theos/include/Foundation/
```

To build the project, you need only run

```
make
```

### Installing

To install this on a jailbroken device, some additional tools are needed.

The first tool is `ldid`, which is used for fakesigning binaries. Ryan Petrich has a build on his [Github mirror](https://github.com/rpetrich/ldid):

``` sh
curl -O http://cloud.github.com/downloads/rpetrich/ldid/ldid.zip
unzip ldid.zip
mv ldid theos/bin/
rm ldid.zip
```

To build a Debian package, `dpkg` and `fakeroot` are required. You can install these from [Homebrew](http://mxcl.github.com/homebrew/):

``` sh
brew install fakeroot dpkg
```

To build a package in the project directory, you can run:

``` sh
make package
```

and to automatically install this package on your jailbroken device (over SSH), you can run:

``` sh
make package install THEOS_DEVICE_IP=xxx.xxx.xxx.xxx
```

## License

GoogleCloudPrint is available under the MIT license. See the LICENSE file for more info.
