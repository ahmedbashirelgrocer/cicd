//
//  BundleExtension.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 15/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

var bundleKey: UInt8 = 0

class AnyLanguageBundle: Bundle {

override func localizedString(forKey key: String,
                              value: String?,
                              table tableName: String?) -> String {

    guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
        let bundle = Bundle(path: path) else {

            return super.localizedString(forKey: key, value: value, table: tableName)
    }

    return bundle.localizedString(forKey: key, value: value, table: tableName)
  }
}

extension Bundle {

 public class func setLanguage(_ language: String) {

    defer {

        object_setClass(Bundle.resource, AnyLanguageBundle.self)
    }
    objc_setAssociatedObject(Bundle.resource, &bundleKey,    Bundle.resource.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
    func localizedStringForKey(key:String, comment:String) -> String {
        return self.localizedString(forKey: key, value: comment, table: nil)
    }
    
    func localizedImagePathForImg(imagename:String, type:String) -> String {
        guard let imagePath =  self.path(forResource: imagename, ofType: type) else {
            return ""
        }
        return imagePath
    }
}
