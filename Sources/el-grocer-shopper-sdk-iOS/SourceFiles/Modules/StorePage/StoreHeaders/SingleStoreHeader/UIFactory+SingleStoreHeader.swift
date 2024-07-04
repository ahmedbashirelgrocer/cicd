//
//  UIFactory+SingleStoreHeader.swift
//  
//
//  Created by saboor Khan on 27/05/2024.
//

import UIKit

extension UIFactory{
    static func makeSingleStoreHeader(presenter: SingleStoreHeaderType)-> SingleStoreHeader {
        let view = SingleStoreHeader(presenter: presenter)
        return view
    }
}
