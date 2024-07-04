//
//  File.swift
//  
//
//  Created by saboor Khan on 07/05/2024.
//

import Foundation
import UIKit

extension UIFactory {
    static func makeStorePageHeader(presenter: StorePageHeaderType) -> StorePageHeader {
        let nib = UINib.init(nibName: "StorePageHeader", bundle: .resource)
        let header = nib.instantiate(withOwner: StorePageHeader.self).first as! StorePageHeader
        header.presenter = presenter
        
        return header
    }
}
