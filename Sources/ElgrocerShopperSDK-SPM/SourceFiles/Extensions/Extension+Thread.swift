//
//  Extension+Thread.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 09/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

extension Thread{
    class func OnMainThread(_ completion: @escaping (()-> Void)){
        if Thread.current.isMainThread{
            completion()
            return
        }else{
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
