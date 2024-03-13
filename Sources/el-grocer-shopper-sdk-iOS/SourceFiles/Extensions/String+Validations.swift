//
//  String+EmailValidation.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 16.06.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func isNotEmtpy() -> Bool {
        return !self.isEmpty
    }
    
    /// Returns true iff other is non-empty and contained within self by case-insensitive search
    
    func contains(_ s: String) -> Bool
    {
        return (self.lowercased().range(of: s.lowercased()) != nil) ? true : false
    }

    func isValidEmail() -> Bool {
        
//        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
//        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        return self.count >= 6 ? true : false
    }
    
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    func  isValidPhoneNumber() -> Bool {
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func convertEngNumToPersianNum()->String{
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if phoneLanguage != nil {
            if phoneLanguage == "ar" {
                let stringNumber : String  = self
                var finalString = ""
                for c in stringNumber {
                    let Formatter = NumberFormatter()
                    Formatter.locale = NSLocale(localeIdentifier: "ar") as Locale?
                    if let final = Formatter.number(from: "\(c)") {
                        finalString = finalString + Formatter.string(from: final)!
                    }
                }
                return finalString
            }
        }
        return self
    }

}
extension String {
    func heightOfString(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func widthOfString(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)

        return ceil(boundingBox.width)
    }
}

extension Array {
    public func stablePartition(by condition: (Element) throws -> Bool) rethrows -> ([Element], [Element]) {
        var indexes = Set<Int>()
        for (index, element) in self.enumerated() {
            if try condition(element) {
                indexes.insert(index)
            }
        }
        var matching = [Element]()
        matching.reserveCapacity(indexes.count)
        var nonMatching = [Element]()
        nonMatching.reserveCapacity(self.count - indexes.count)
        for (index, element) in self.enumerated() {
            if indexes.contains(index) {
                matching.append(element)
            } else {
                nonMatching.append(element)
            }
        }
        return (matching, nonMatching)
    }
    
}
