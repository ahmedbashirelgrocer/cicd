//
//  String+Extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import Foundation
extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
