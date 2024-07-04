//
//  UIFactory+StoreExclusiveDealsListView.swift
//  
//
//  Created by saboor Khan on 25/05/2024.
//

import UIKit

extension UIFactory {
    
    static func makeStoreExclusiveDealsaListView(presenter: StoreExclusiveDealsListViewType) -> StoreExclusiveDealsListView {
        let view = StoreExclusiveDealsListView(presenter: presenter)
        return view
    }
    
}
