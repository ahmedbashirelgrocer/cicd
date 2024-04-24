// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "el-grocer-shopper-sdk-iOS",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "el-grocer-shopper-sdk-iOS",
            targets: ["el-grocer-shopper-sdk-iOS"]
        ),
    ],
    
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.4.0")),
        .package(url: "https://github.com/Netvent/storyly-ios", from: "2.13.0"),
        .package(url: "https://github.com/malcommac/SwiftDate", from: "6.3.1"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "3.5.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0"),
        .package(url: "https://github.com/Adyen/adyen-ios", from: "4.10.2"),
        .package(url: "https://github.com/segmentio/analytics-ios", from: "4.1.8"),
        .package(url: "https://github.com/sendbird/sendbird-chat-sdk-ios", from: "4.10.0"),
        .package(url: "https://github.com/sendbird/sendbird-uikit-ios-spm.git", from: "3.6.2"),
        .package(url: "https://github.com/sendbird/SendBird-Desk-iOS-Framework", from: "1.1.3"),
        .package(url: "https://github.com/nicklockwood/FXPageControl", from: "1.5.0"),
        .package(url: "https://github.com/CleverTap/clevertap-segment-ios.git", .exact("1.2.6")),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "4.1.4"),
        .package(url: "https://github.com/CleverTap/clevertap-ios-sdk.git", .exact("5.0.1")),
        .package(url: "https://github.com/KennethTsang/GrowingTextView", from: "0.7.2"),
        .package(url: "https://github.com/SwiftKickMobile/SwiftMessages", from: "9.0.9"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager", from: "6.5.9"),
        .package(url: "https://github.com/Skyscanner/SkyFloatingLabelTextField", from: "3.0.0"),
        .package(url: "https://github.com/rwbutler/AnimatedGradientView", from: "3.1.0"),
        .package(url: "https://github.com/algolia/instantsearch-ios", .exact("7.26.1")),
        .package(url: "https://github.com/algolia/algoliasearch-client-swift", .exact("8.19.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources", from: "4.0.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.1"),
        .package(url: "https://github.com/googlemaps/ios-maps-sdk", .exact("8.4.0")),
        .package(url: "https://github.com/googlemaps/ios-places-sdk", from: "8.3.0"),
        .package(url: "https://github.com/MaherKSantina/MSPeekCollectionViewDelegateImplementation", from: "3.2.0"),
        .package(url: "https://github.com/segment-integrations/analytics-ios-integration-firebase", from: "2.7.10")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "el-grocer-shopper-sdk-iOS",
            dependencies: [
                "ThirdPartyObjC",
                // Firebase
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDynamicLinks", package: "firebase-ios-sdk"),
                
                // Adyen
                .product(name: "Adyen", package: "adyen-ios"),
                .product(name: "AdyenActions", package: "adyen-ios"),
                .product(name: "AdyenCard", package: "adyen-ios"),
                .product(name: "AdyenComponents", package: "adyen-ios"),
                
                // Sendbird
                .product(name: "SendbirdUIKit", package: "sendbird-uikit-ios-spm"),
                .product(name: "SendbirdChatSDK", package: "sendbird-chat-sdk-ios"),
                .product(name: "SendBirdDesk", package: "SendBird-Desk-iOS-Framework"),
                
                // Analytics
                .product(name: "Segment", package: "analytics-ios"),
                .product(name: "Segment-CleverTap", package: "clevertap-segment-ios"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "CleverTapSDK", package: "clevertap-ios-sdk"),
                .product(name: "SegmentFirebase", package: "analytics-ios-integration-firebase"),
                
                // Rx
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
            
//                // Google
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
                .product(name: "GoogleMapsBase", package: "ios-maps-sdk"),
                .product(name: "GoogleMapsCore", package: "ios-maps-sdk"),
                .product(name: "GooglePlaces", package: "ios-places-sdk"),
                
                // Algolia
                .product(name: "AlgoliaSearchClient", package: "algoliasearch-client-swift"),
                .product(name: "InstantSearch", package: "instantsearch-ios"),
                
                // Utilities
                .product(name: "Storyly", package: "storyly-ios"),
                .product(name: "SwiftDate", package: "SwiftDate"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "FXPageControl", package: "FXPageControl"),
                .product(name: "GrowingTextView", package: "GrowingTextView"),
                .product(name: "SwiftMessages", package: "SwiftMessages"),
                .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
                .product(name: "SkyFloatingLabelTextField", package: "SkyFloatingLabelTextField"),
                .product(name: "AnimatedGradientView", package: "AnimatedGradientView"),
                .product(name: "MSPeekCollectionViewDelegateImplementation", package: "MSPeekCollectionViewDelegateImplementation"),
            ],
            resources: [
                .copy("Resources/SupportingFiles/EnvironmentVariables.plist"),
                .copy("Resources/SupportingFiles/GoogleService-Info-ProdV2.plist"),
                .copy("Resources/SupportingFiles/GoogleService-Info-SandBox.plist"),
                .copy("Resources/SupportingFiles/GoogleService-Info-SDK.plist"),
                .copy("Resources/SupportingFiles/GoogleService-Info-Smiles-PreProd.plist"),
                .copy("Resources/SupportingFiles/GoogleService-Info-Smiles.plist"),
                .copy("Resources/SupportingFiles/GoogleService-Info.plist"),
                .copy("Resources/SupportingFiles/HelpshiftConfig.plist"),
                .copy("Resources/SupportingFiles/ProductConfigDefaults.plist"),
                .copy("Resources/SupportingFiles/Tobacco.plist"),
                .copy("ThirdPartySwift/FlagPhoneNumber/Resources/countryCodes.json"),
                .copy("Resources/FontFiles/ArabicMarkaziText/MarkaziText-Bold.ttf"),
                .copy("Resources/FontFiles/ArabicMarkaziText/MarkaziText-Medium.ttf"),
                .copy("Resources/FontFiles/ArabicMarkaziText/MarkaziText-Regular.ttf"),
                .copy("Resources/FontFiles/ArabicMarkaziText/MarkaziText-SemiBold.ttf"),
                .copy("Resources/FontFiles/Gotham-Black.otf"),
                .copy("Resources/FontFiles/Gotham-Bold.otf"),
                .copy("Resources/FontFiles/Gotham-Book-Italic.otf"),
                .copy("Resources/FontFiles/Gotham-Book.otf"),
                .copy("Resources/FontFiles/Gotham-Light-Italic.otf"),
                .copy("Resources/FontFiles/Gotham-Light.otf"),
                .copy("Resources/FontFiles/Gotham-Medium.otf"),
                .copy("Resources/FontFiles/Gotham-Thin.otf"),
                .copy("Resources/FontFiles/Gotham-Ultra.otf"),
                .copy("Resources/FontFiles/OpenSans-Bold.ttf"),
                .copy("Resources/FontFiles/OpenSans-BoldItalic.ttf"),
                .copy("Resources/FontFiles/OpenSans-ExtraBold.ttf"),
                .copy("Resources/FontFiles/OpenSans-ExtraBoldItalic.ttf"),
                .copy("Resources/FontFiles/OpenSans-Italic.ttf"),
                .copy("Resources/FontFiles/OpenSans-Light.ttf"),
                .copy("Resources/FontFiles/OpenSans-LightItalic.ttf"),
                .copy("Resources/FontFiles/OpenSans-Regular.ttf"),
                .copy("Resources/FontFiles/OpenSans-Semibold.ttf"),
                .copy("Resources/FontFiles/OpenSans-SemiboldItalic.ttf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Black.otf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Bold.otf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Heavy.otf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Light.otf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Medium.otf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Regular.otf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Semibold.otf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Thin.otf"),
                .copy("Resources/FontFiles/SanFranciscoDisplay-Ultralight.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-Bold.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-BoldItalic.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-Heavy.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-HeavyItalic.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-Light.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-LightItalic.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-Medium.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-MediumItalic.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-Regular.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-RegularItalic.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-Semibold.otf"),
                .copy("Resources/FontFiles/SanFranciscoText-SemiboldItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Black.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-BlackItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Bold.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-BoldItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Heavy.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-HeavyItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Light.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-LightItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Medium.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-MediumItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Regular.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-RegularItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Semibold.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-SemiboldItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Thin.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-ThinItalic.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-Ultralight.otf"),
                .copy("Resources/FontFiles/SF-Pro-Display-UltralightItalic.otf"),
                .copy("Resources/FontFiles/SF-UI-Display-Medium.otf"),
                .copy("Resources/FontFiles/SF-UI-Display-Regular.otf"),
                .copy("Resources/FontFiles/SF-UI-Display-Semibold.otf"),
                .copy("Resources/VersionInfo.plist")
            ]
        ),
        
        .target(
            name: "ThirdPartyObjC",
            dependencies: [],
            sources: [""],
            publicHeadersPath: "include"
        )
    ]
)
