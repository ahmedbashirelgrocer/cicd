//
//  StoreBuyItAgainCollectionViewCellPresenter.swift
//  
//
//  Created by saboor Khan on 14/05/2024.
//

import UIKit

class StoreBuyItAgainCollectionViewCellPresenter {
    
    let imageUrl: String
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}

extension StoreBuyItAgainCollectionViewCellPresenter: ReusableTableViewCellPresenterType {
    var reusableIdentifier: String { StoreBuyItAgainCollectionViewCell.defaultIdentifier }
}
