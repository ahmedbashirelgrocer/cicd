//
//  Bundle+Extension.swift
//  ElgrocerDummySmile
//
//  Created by Sarmad Abbas on 09/06/2022.
//

import Foundation

private let RESOURCE_NAME = "el-grocer-shopper-sdk-iOS"

extension Bundle {
    static var resource: Bundle {
        let myBundle = Bundle(for: GetBundleClass.self)
        // Get the URL to the resource bundle within the bundle
        // of the current class.
        guard let resourceBundleURL = myBundle.url(
            forResource: RESOURCE_NAME, withExtension: "bundle")
        else { fatalError("\(RESOURCE_NAME).bundle not found!") }
        // Create a bundle object for the bundle found at that URL.
        guard let bundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access \(RESOURCE_NAME).bundle!") }
        return bundle
    }
    
}

extension Bundle {
    
        /// The main bundle of the framework.
    internal static let appCore: Bundle = .init(for: GetBundleClass.self)
    
        /// The bundle in which the framework's resources are located.
    internal static let languageResource: Bundle = {
        let url = appCore.url(forResource: "el-grocer-shopper-sdk-iOS", withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        return bundle ?? appCore
    }()
    
}

public enum elGrocerSDKConfiguration {
    static var version: String {
        guard let version = Bundle.resource
                .infoDictionary?["CFBundleShortVersionString"] as? String else { return "Unknown" }
        return version
    }
    
    static var superAppVersion: String {
        guard let version = Bundle.main
                .infoDictionary?["CFBundleShortVersionString"] as? String else { return "Unknown" }
        return version
    }
  
}



//extension Bundle {
//
//        /// The main bundle of the framework.
//    private static let langBundle: Bundle = .init(for: GetBundleClass.self)
//
//        /// The bundle in which the framework's resources are located.
//    internal static var langInternalResources: Bundle {
//        let url = langBundle.url(forResource: "adyenAr", withExtension: "strings")
//        let bundle = url.flatMap { Bundle(url: $0) }
//        return bundle ?? langBundle
//    }
//
//}


private final class GetBundleClass { }
