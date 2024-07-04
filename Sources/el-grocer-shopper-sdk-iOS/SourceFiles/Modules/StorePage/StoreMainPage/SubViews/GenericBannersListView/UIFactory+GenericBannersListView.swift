//
//  File.swift
//  
//
//  Created by saboor Khan on 14/05/2024.
//

import UIKit

extension UIFactory {
    
    static func makeGenericBannersListView(presenter: GenericBannersListViewType) -> GenericBannersListView {
        let bannerView = GenericBannersListView(presenter: presenter)
        return bannerView
    }
    
}
