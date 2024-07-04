//
//  StoreExclusiveDealsListViewPresenter.swift
//  
//
//  Created by saboor Khan on 25/05/2024.
//

import UIKit

protocol StoreExclusiveDealsListViewInputs: AnyObject {
    // internal use
    func setInitialisers(grocery: Grocery, promoList: [ExclusiveDealsPromoCode])
    func promoTapHandler(promo: ExclusiveDealsPromoCode)
}

protocol StoreExclusiveDealsListViewOutputs: AnyObject {
    //Data sets
    func setBanners()
    func getCellViewModels(_ value: [[StoreExclusiveDealCollectionCellPresenter]])
}

protocol StoreExclusiveDealsListViewDelegate: AnyObject {
    //Navigations
    func promoTapHandler(promo: ExclusiveDealsPromoCode)
}

extension StoreExclusiveDealsListViewDelegate {
    func promoTapHandler(promo: ExclusiveDealsPromoCode) { }
}

protocol StoreExclusiveDealsListViewType {
    var inputs: StoreExclusiveDealsListViewInputs? { get }
    var delegateOutputs: StoreExclusiveDealsListViewOutputs? { get set }
    var delegate: StoreExclusiveDealsListViewDelegate? { get set }
}


class StoreExclusiveDealsListViewPresenter: StoreExclusiveDealsListViewType {
    
    //inputs
    var grocery: Grocery!
    var promoList: [ExclusiveDealsPromoCode] = []
    
    weak var inputs: StoreExclusiveDealsListViewInputs? { self }
    weak var delegateOutputs: StoreExclusiveDealsListViewOutputs?
    weak var delegate: StoreExclusiveDealsListViewDelegate?
    
    init(delegate: StoreExclusiveDealsListViewDelegate?) {
        self.delegate = delegate
    }
    
    func configure() {
        var cellViewModels: [[ReusableTableViewCellPresenterType]] = []
        var presenters: [StoreExclusiveDealCollectionCellPresenter] = []
        for promo in promoList {
            let vm = StoreExclusiveDealCollectionCellPresenter(promo: promo, grocery: grocery)
            presenters.append(vm)
        }
        
        cellViewModels.append(presenters)
        
        self.delegateOutputs?.getCellViewModels(cellViewModels as! [[StoreExclusiveDealCollectionCellPresenter]])
    }
}

extension StoreExclusiveDealsListViewPresenter: StoreExclusiveDealsListViewInputs {
    func setInitialisers(grocery: Grocery, promoList: [ExclusiveDealsPromoCode]) {
        self.grocery = grocery
        self.promoList = promoList
        self.configure()
        
    }
    
    func promoTapHandler(promo: ExclusiveDealsPromoCode) {
        self.delegate?.promoTapHandler(promo: promo)
    }
}
