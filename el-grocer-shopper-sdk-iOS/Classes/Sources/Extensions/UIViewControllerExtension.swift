//
//  UIViewControllerExtension.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 07/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

extension UIViewController {
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        guard arr.count > fromIndex else { return arr }
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        return arr
    }
}
