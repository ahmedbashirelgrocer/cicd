//
//  CellDescriptor.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 11/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

class CellDescriptor: NSObject {
    
    var cellIdentifier: String = ""
    
    var isExpandable: Bool = true
    var isExpanded: Bool = true
    var isVisible: Bool = true
    
    var order:Order!
    var product:Product!
    
    var products:[Product] = [Product]()
}
