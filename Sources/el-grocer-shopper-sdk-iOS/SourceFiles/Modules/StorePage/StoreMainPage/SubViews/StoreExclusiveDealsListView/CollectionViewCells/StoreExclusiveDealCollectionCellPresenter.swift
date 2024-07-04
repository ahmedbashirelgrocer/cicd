//
//  StoreExclusiveDealCollectionCellPresenter.swift
//  
//
//  Created by saboor Khan on 25/05/2024.
//

import UIKit

class StoreExclusiveDealCollectionCellPresenter {
    
    let promo: ExclusiveDealsPromoCode
    let grocery: Grocery
    
    init(promo: ExclusiveDealsPromoCode, grocery: Grocery) {
        self.promo = promo
        self.grocery = grocery
    }

}

extension StoreExclusiveDealCollectionCellPresenter: ReusableTableViewCellPresenterType {
    var reusableIdentifier: String { StoreExclusiveDealCollectionCell.defaultIdentifier }
}
