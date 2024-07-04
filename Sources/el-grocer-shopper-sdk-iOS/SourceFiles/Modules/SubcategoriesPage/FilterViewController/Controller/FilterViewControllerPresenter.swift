//
//  FilterViewControllerPresenter.swift
//  
//
//  Created by saboor Khan on 05/06/2024.
//

import UIKit

let kFilterDiscountedBrandID: Int = -100

struct ProductFilters: Equatable {
    var txtSearch: String
    var isPromotion: Bool
    var brandsArray: [(_brand: BrandDTO,_isSelected: Bool)]
    var filterCount: Int
    
    static func == (lhs: ProductFilters, rhs: ProductFilters) -> Bool {
        return lhs.txtSearch == rhs.txtSearch && lhs.isPromotion == rhs.isPromotion && lhs.brandsArray.count == rhs.brandsArray.count && lhs.filterCount == rhs.filterCount
    }
}

protocol FilterViewControllerPresenterInputs: AnyObject {
    // internal use
    func updateText(text: String)
    func updateBrand(brand: BrandDTO, isSelected: Bool)
    func btnApplyPressed()
    func btnResetPressed()
    func viewWillAppear()
}

protocol FilterViewControllerPresenterOutputs: AnyObject {
    //Data sets
    func getSearchText(text: String)
    func getCellViewModels(_ value: [[FiltersBrandTableViewCellPresenter]])
}

protocol FilterViewControllerPresenterDelegate: AnyObject {
    //Navigations
    func btnApplyPressed(data: ProductFilters)
}

extension FilterViewControllerPresenterDelegate {
    func btnApplyPressed(data: ProductFilters) {}
}

protocol FilterViewControllerPresenterType {
    var inputs: FilterViewControllerPresenterInputs? { get }
    var delegateOutputs: FilterViewControllerPresenterOutputs? { get set }
    var delegate: FilterViewControllerPresenterDelegate? { get set }
}

class FilterViewControllerPresenter: FilterViewControllerPresenterType {
    
    var inputs: FilterViewControllerPresenterInputs?  { self }
    var delegateOutputs: FilterViewControllerPresenterOutputs?
    var delegate: FilterViewControllerPresenterDelegate?
    
    var data: ProductFilters!
    private var subCategory: SubCategory?
    private var category: CategoryDTO
    private var grocery: Grocery
    
    init(data: ProductFilters?, delegate: FilterViewControllerPresenterDelegate, subCategory: SubCategory?, grocery: Grocery, category: CategoryDTO) {
        self.delegate = delegate
        self.subCategory = subCategory
        self.grocery = grocery
        self.category = category
        self.data = data ?? ProductFilters(txtSearch: "", isPromotion: false, brandsArray: [], filterCount: 0)
    }
    
    func configure(data: ProductFilters) {
        // need to show discounted product on top creating local view model for it
        let disCountedBrand = BrandDTO(id: kFilterDiscountedBrandID, name: localizedString("title_discounted_products", comment: ""), imageURL: "", slug: "")
        let disCountedProductVM = FiltersBrandTableViewCellPresenter(brand: disCountedBrand, isSelected: data.isPromotion)
        
        var cellViewModels: [[ReusableTableViewCellPresenterType]] = []
        var presenters: [FiltersBrandTableViewCellPresenter] = []
        
        for data in data.brandsArray {
            let vm = FiltersBrandTableViewCellPresenter(brand: data._brand, isSelected: data._isSelected)
            presenters.append(vm)
        }
        cellViewModels.append([disCountedProductVM])
        if presenters.count > 0 {
            cellViewModels.append(presenters)
        }
        
        
        self.delegateOutputs?.getCellViewModels(cellViewModels as! [[FiltersBrandTableViewCellPresenter]])
        delegateOutputs?.getSearchText(text: data.txtSearch)
    }
    
    private func getFilterCount()-> Int {
        var count: Int = 0
        if data.txtSearch.count > 0 {
            count = count + 1
        }
        if data.isPromotion {
            count = count + 1
        }
        let selectedBrands = data.brandsArray.filter { (_brand: BrandDTO, _isSelected: Bool) in
            return _isSelected
        }
        count = count + selectedBrands.count
        
        return count
    }
    
    private func resetBrandArray()-> [(_brand: BrandDTO, _isSelected: Bool)] {
        var arrayToSend:[(_brand: BrandDTO, _isSelected: Bool)] = []
        for data in self.data.brandsArray {
            var obj = data
            obj._isSelected = false
            arrayToSend.append(obj)
        }
        return arrayToSend
    }
}
extension FilterViewControllerPresenter: FilterViewControllerPresenterInputs {
    func viewWillAppear() {
        configure(data: data)
    }
    
    func btnApplyPressed() {
        
        data.filterCount = self.getFilterCount()
        self.delegate?.btnApplyPressed(data: data)
    }
    
    func btnResetPressed() {
        let brandsArray = resetBrandArray()
        self.data = ProductFilters(txtSearch: "", isPromotion: false, brandsArray: brandsArray, filterCount: 0)
        configure(data: data)
        
    }
    func updateText(text: String) {
        self.data.txtSearch = text
        self.delegateOutputs?.getSearchText(text: text)
    }

    func updateBrand(brand: BrandDTO, isSelected: Bool) {
        // check discountBrand
        if brand.id == kFilterDiscountedBrandID {
            data.isPromotion = isSelected
            return
        }
        // update brand is selected or not
        if let index = data.brandsArray.firstIndex (where: { brandDTO, isSelected in
            return brandDTO.id == brand.id
        }) {
            self.data.brandsArray[index] = (brand, isSelected)
        }
    }
    
}
//MARK: Helper
extension FilterViewControllerPresenter {
    func calculateHeight()-> CGFloat {
        var totalHeight: CGFloat = 0
        let count = data.brandsArray.count
        let minimumHeight: CGFloat = 330
        let headerHeight: CGFloat = 48
        let singleRowHeight: CGFloat = 48
        let separatorHeight: CGFloat = 48
        
        let rowsHeight = singleRowHeight * CGFloat(count)
        
        if count > 0 {
            totalHeight = minimumHeight + headerHeight + rowsHeight + separatorHeight
            if count > 5 {
                totalHeight = ScreenSize.SCREEN_HEIGHT * 0.75
            }
        }else {
            totalHeight = minimumHeight
        }
        
        return totalHeight
    }
}
