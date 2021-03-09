# MyPackage

Minimal complication error example. 

I'm in the process of migrating an iOS app to use the latest version of a storage SDK. The previous SDK provided a model abstraction similar to CoreData, which leverages the dynamic nature of Objective-C. Since I have access to the Obj-C model source code, I'm using composition to implement the model storage functionality, along with many of the support classes, in Swift. This results in a mixed source package that is similar to the following...

```
let package = Package(
    name: "MyPackage",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]),
        .library(
            name: "MyPackageObjC",
            targets: ["MyPackageObjC"]),
        .library(
            name: "MyPackageSwift",
            targets: ["MyPackageSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyPackage",
            dependencies: ["MyPackageSwift","MyPackageObjC"]),
        .target(
            name: "MyPackageObjC",
            dependencies: ["MyPackageSwift"]),
        .target(
            name: "MyPackageSwift",
            dependencies: []),
        .testTarget(
            name: "MyPackageTests",
            dependencies: ["MyPackage"]),
    ]
)
```

And a file system layout that looks like....

```
.
├── Package.swift
    ├── README.md
    ├── Sources
    │   ├── MyPackage
    │   │   └── Export.swift
    │   ├── MyPackageObjC
    │   │   ├── MyObject.m
    │   │   ├── NameGenerator+LastName.m
    │   │   └── include
    │   │       ├── MyObject.h
    │   │       └── NameGenerator+LastName.h
    │   └── MyPackageSwift
    │       └── MyPackage.swift
    └── Tests
        ├── LinuxMain.swift
        └── MyPackageTests
            ├── MyPackageTests.swift
            └── XCTestManifests.swift
```

Since the Swift target cannot depend on the Obj-C target, I've added categories in Obj-C to implement interactions with the model class. For example, since my Swift model factory class cannot import the Obj-C model class, I've implemented the method that creates the model from a underlying document as an Obj-C category on the Swift class. This works well when I build the MyPackageObjC target, and I can use the resulting package in Obj-C code in my app. However, this fails when I try to import the MyPackageObjC target in Swift. I created the MyPackage target that depends on both the Obj-C and Swift targets a means to factor the iOS app out of the equation. Export.swift uses @_exported import MyPackage<variant> to replicate what happens in the iOS app.

From the file NameGenerator+LastName.h in my minimal test project....

```
@import MyPackageSwift; <- error when building 'MyPackage' 

@interface NameGenerator (LastName)

- (NSString*)generateLastName;

@end
```

Here's a high level output of the error...

```
<module-includes>:1:9: note: in file included from <module-includes>:1:
#import "/Users/scott/Desktop/MyPackage/Sources/MyPackageObjC/include/NameGenerator+LastName.h"
        ^
/Users/scott/Desktop/MyPackage/Sources/MyPackageObjC/include/NameGenerator+LastName.h:2:9: error: module 'MyPackageSwift' not found
@import MyPackageSwift;
        ^
/Users/scott/Desktop/MyPackage/Sources/MyPackage/Export.swift:2:19: error: could not build Objective-C module 'MyPackageObjC'
@_exported import MyPackageObjC
```

After digging a bit deeper, I discovered that adding @import MyPackageSwift to any header in the Obj-C target causes this error when building the MyPackage target. But it works fine when building the Obj-C MyPackageObjC target.

Since this seems to work conditionally, is there any additional package compiler configuration entries I can use to resolve this?

What seems odd here is that the Obj-C target builds successfully earlier in the process. It's almost as if the Swift compiler is trying to compile the Obj-C header file through a traversal of @_exported import MyPackageObjC in the MyPackage Export.swift file. Does this only "work" for Swift targets?


