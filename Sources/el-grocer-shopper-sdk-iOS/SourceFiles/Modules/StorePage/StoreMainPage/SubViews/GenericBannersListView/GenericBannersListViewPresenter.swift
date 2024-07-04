//
//  File.swift
//  
//
//  Created by saboor Khan on 07/05/2024.
//

import Foundation
import UIKit

protocol GenericBannersListViewInputs: AnyObject {
    // internal use
    func setInitialisers(grocery: Grocery, banners: [BannerDTO])
    func bannerTapHandler(banner: BannerDTO,index: Int)
}

protocol GenericBannersListViewOutputs: AnyObject {
    //Data sets
    func setBanners()
    func getCellViewModels(_ value: [[GenericBannersCollectionCellPresenter]])
}

protocol GenericBannersListViewDelegate: AnyObject {
    //Navigations
    func bannerTapHandler(banner: BannerDTO, index: Int)
}

extension GenericBannersListViewDelegate {
    func bannerTapHandler(banner: BannerDTO) { }
}

protocol GenericBannersListViewType {
    var inputs: GenericBannersListViewInputs? { get }
    var delegateOutputs: GenericBannersListViewOutputs? { get set }
    var delegate: GenericBannersListViewDelegate? { get set }
}


class GenericBannersListViewPresenter: GenericBannersListViewType {
    
    //inputs
    var grocery: Grocery!
    var bannerList: [BannerDTO] = []
    
    weak var inputs: GenericBannersListViewInputs? { self }
    weak var delegateOutputs: GenericBannersListViewOutputs?
    weak var delegate: GenericBannersListViewDelegate?
    
    init(delegate: GenericBannersListViewDelegate?) {
        self.delegate = delegate
    }
    
    func configure() {
        var cellViewModels: [[ReusableTableViewCellPresenterType]] = []
        var bannerPresenters: [GenericBannersCollectionCellPresenter] = []
        for banner in bannerList {
            let vm = GenericBannersCollectionCellPresenter(banner: banner)
            bannerPresenters.append(vm)
        }
        
        cellViewModels.append(bannerPresenters)
        
        self.delegateOutputs?.getCellViewModels(cellViewModels as! [[GenericBannersCollectionCellPresenter]])
    }
}

extension GenericBannersListViewPresenter: GenericBannersListViewInputs {
    func setInitialisers(grocery: Grocery, banners: [BannerDTO]) {
        self.grocery = grocery
        self.bannerList = banners
        self.configure()
        
    }
    
    func bannerTapHandler(banner: BannerDTO, index: Int) {
        self.delegate?.bannerTapHandler(banner: banner, index: index)
    }
}
