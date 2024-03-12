//
//  Either.swift
//  ElGrocerShopper
//
//  Created by Piotr Gorzelany on 25/02/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation

enum Either<T> {
    
    case success(T)
    case failure(ElGrocerError)
    
}
