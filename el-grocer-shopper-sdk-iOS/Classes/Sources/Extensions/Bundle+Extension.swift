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
    
    static var source_files: Bundle { return Bundle(for: GetBundleClass.self) }
}

private final class GetBundleClass { }
