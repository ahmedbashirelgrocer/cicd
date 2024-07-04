//
//  File.swift
//  
//
//  Created by Rashid Khan on 28/05/2024.
//

import Foundation
import RxSwift

protocol CustomCampignProductsViewPresenterInput { 
    func updateData(products: [ProductDTO], grocery: Grocery?, bannerCampaign: BannerCampaign?)
    func imageBannerTapped()
}

protocol CustomCampignProductsViewPresenterOutput: AnyObject { 
    func productCellVMsAvailable(_ productCellVMs: [ReusableCollectionViewCellViewModelType])
    func bannerImageUrl(_ url: URL)
    func backgroundColor(_ color: String?)
}

protocol CustomCampignProductsViewPresenterAction: AnyObject { 
    func basketUpdated()
    func viewAllTapped(bannerCampaign: BannerCampaign?)
}

protocol CustomCampignProductsViewPresenterType { 
    var inputs: CustomCampignProductsViewPresenterInput? { get }
    var outputs: CustomCampignProductsViewPresenterOutput? { get set }
    var actions: CustomCampignProductsViewPresenterAction? { get set }
}

class CustomCampignProductsViewPresenter: CustomCampignProductsViewPresenterType {
    var inputs: CustomCampignProductsViewPresenterInput? { self }
    weak var outputs: CustomCampignProductsViewPresenterOutput?
    weak var actions: CustomCampignProductsViewPresenterAction?
    
    private var bannerCampaign: BannerCampaign?
    private var disposeBag = DisposeBag()
    
    init(action: CustomCampignProductsViewPresenterAction) {
        self.actions = action
    }
}

extension CustomCampignProductsViewPresenter: CustomCampignProductsViewPresenterInput { 
    func updateData(products: [ProductDTO], grocery: Grocery?, bannerCampaign: BannerCampaign?) {
        self.bannerCampaign = bannerCampaign
        
        var productCellVMs: [ReusableCollectionViewCellViewModelType] = products.map {
            let vm = ProductCellViewModel(product: $0, grocery: grocery)
            vm.outputs.basketUpdated.subscribe { _ in
                self.actions?.basketUpdated()
            }.disposed(by: disposeBag)
            
            return vm
        }
        
        if productCellVMs.isNotEmpty {
            let viewAllVM = ViewAllCollectionCellViewModel()
            
            viewAllVM.outputs.viewAllTap.subscribe { _ in
                self.actions?.viewAllTapped(bannerCampaign: self.bannerCampaign)
            }.disposed(by: disposeBag)
            
            productCellVMs.append(viewAllVM)
        }
        
        self.outputs?.productCellVMsAvailable(productCellVMs)
        
        if let imageUrl = bannerCampaign?.bannerImageUrl, let url = URL(string: imageUrl) {
            self.outputs?.bannerImageUrl(url)
        }
        
        self.outputs?.backgroundColor(bannerCampaign?.backgroundColor)
    }
    
    func imageBannerTapped() {
        self.actions?.viewAllTapped(bannerCampaign: self.bannerCampaign)
    }
}
