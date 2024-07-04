//
//  File.swift
//  
//
//  Created by saboor Khan on 14/05/2024.
//

import UIKit

extension UIFactory {
    
    static func makeStoreMainCategoriesView(presenter: StoreMainCategoriesViewType) -> StoreMainCategoriesView {
        let view = StoreMainCategoriesView(presenter: presenter)
        return view
    }
    
}
