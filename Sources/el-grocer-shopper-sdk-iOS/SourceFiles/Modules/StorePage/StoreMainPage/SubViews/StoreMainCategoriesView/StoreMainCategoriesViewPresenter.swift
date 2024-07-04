//
//  StoreMainCategoriesViewPresenter.swift
//  
//
//  Created by saboor Khan on 12/05/2024.
//

import UIKit

protocol StoreMainCategoriesViewInputs: AnyObject {
    // internal use
    func setInitialisers(grocery: Grocery, categories: [CategoryDTO])
    func categoryTapHandler(category: CategoryDTO)
    func viewHideAllCategories(isExpanded: Bool)
}

protocol StoreMainCategoriesViewOutputs: AnyObject {
    //Data sets
    func getCellViewModels(_ value: [[StoreMainCategoriesCollectionViewCellPresenter]])
    func getCollectionViewHeight(height: CGFloat)
    func getCollectionCellSize(size: CGSize)
    func getbuttonState(btnViewAllVisible: Bool, btnHideAllVisible: Bool)
}

protocol StoreMainCategoriesViewDelegate: AnyObject {
    //Navigations
    func categoryTapHandler(category: CategoryDTO, categories: [CategoryDTO])
}

extension StoreMainCategoriesViewDelegate {
    func categoryTapHandler(category: CategoryDTO, categories: [CategoryDTO]) { }
}

protocol StoreMainCategoriesViewType {
    var inputs: StoreMainCategoriesViewInputs? { get }
    var delegateOutputs: StoreMainCategoriesViewOutputs? { get set }
    var delegate: StoreMainCategoriesViewDelegate? { get set }
}


class StoreMainCategoriesViewPresenter: StoreMainCategoriesViewType {

    //inputs
    var grocery: Grocery!
    var categoryList: [CategoryDTO] = []
    private var cellVMs: [[ReusableTableViewCellPresenterType]] = []
    
    weak var inputs: StoreMainCategoriesViewInputs? { self }
    weak var delegateOutputs: StoreMainCategoriesViewOutputs?
    weak var delegate: StoreMainCategoriesViewDelegate?
    
    init(delegate: StoreMainCategoriesViewDelegate?) {
        self.delegate = delegate
    }
    
    func configure() {
        var cellViewModels: [[ReusableTableViewCellPresenterType]] = []
        var categoryPresenters: [StoreMainCategoriesCollectionViewCellPresenter] = []
        for category in categoryList {
            let vm = StoreMainCategoriesCollectionViewCellPresenter(category: category)
            categoryPresenters.append(vm)
        }
        
        cellViewModels.append(categoryPresenters)
        self.cellVMs = cellViewModels
        let cellSize = self.getCellSize()
        
        self.getCollectionViewHeight(cellViewModels: cellViewModels, isExpanded: false)
        self.getButtonsState(isExpanded: false)
        self.delegateOutputs?.getCollectionCellSize(size: cellSize)
        self.delegateOutputs?.getCellViewModels(cellViewModels as! [[StoreMainCategoriesCollectionViewCellPresenter]])
    }
    
    private func getCellSize()-> CGSize {
        let cellSpacing: CGFloat = 24
        let padding: CGFloat = 32 // left right
        let textSize: CGFloat = 21
        let screenWidth = ScreenSize.SCREEN_WIDTH - ((cellSpacing) + (padding))
        let finalWidth = screenWidth / 4
        return CGSize(width: finalWidth, height: finalWidth + textSize)
    }
    
    private func getCollectionViewHeight(cellViewModels: [[ReusableTableViewCellPresenterType]], isExpanded: Bool) {
        guard let vms = cellViewModels.first as? [StoreMainCategoriesCollectionViewCellPresenter] else {return}
        let numOfCellsInRow = 4
        let singleRowHeight = Double(getCellSize().height)
        var numOfRows = Double((cellViewModels.first?.count ?? 0)/numOfCellsInRow)
        var paddingHeight: Double = 0
        var height: Double = 0
        
        if (vms.first?.category.customPage != nil) {
            let vmCountWithoutRow1 = Double(vms.count) - 3
            numOfRows = (vmCountWithoutRow1 / Double(numOfCellsInRow)) + Double(1)
            numOfRows = numOfRows.rounded(.up)
            
            if isExpanded {
                paddingHeight = (numOfRows - 1) * 8
                height = singleRowHeight * numOfRows
            }else {
                if numOfRows > 2 {
                    height = singleRowHeight * 2.5
                }else {
                    paddingHeight = (numOfRows - 1) * 8
                    height = singleRowHeight * numOfRows
                }
            }
        }else {
            numOfRows = (Double(vms.count) / Double(numOfCellsInRow))
            numOfRows = numOfRows.rounded(.up)
            if isExpanded {
                paddingHeight = (numOfRows - 1) * 8
                height = singleRowHeight * numOfRows
            }else {
                if numOfRows > 2 {
                    height = singleRowHeight * 2.5
                }else {
                    paddingHeight = (numOfRows - 1) * 8
                    height = singleRowHeight * numOfRows
                }
            }
        }
        self.delegateOutputs?.getCollectionViewHeight(height: CGFloat(height + paddingHeight))
    }
    
    func getButtonsState(isExpanded: Bool) {
        guard let vms = self.cellVMs.first as? [StoreMainCategoriesCollectionViewCellPresenter] else {return}
        let numOfCellsInRow = 4
        var numOfRows = Double((cellVMs.first?.count ?? 0)/numOfCellsInRow)
        
        if (vms.first?.category.customPage != nil) {
            let vmCountWithoutRow1 = Double(vms.count) - 3
            numOfRows = (vmCountWithoutRow1 / Double(numOfCellsInRow)) + Double(1)
            numOfRows = numOfRows.rounded(.up)
            
            if isExpanded {
                self.delegateOutputs?.getbuttonState(btnViewAllVisible: false, btnHideAllVisible: true)
            }else {
                if numOfRows > 2 {
                    self.delegateOutputs?.getbuttonState(btnViewAllVisible: true, btnHideAllVisible: false)
                }else {
                    self.delegateOutputs?.getbuttonState(btnViewAllVisible: false, btnHideAllVisible: false)
                }
            }
        }else {
            numOfRows = (Double(vms.count) / Double(numOfCellsInRow))
            numOfRows = numOfRows.rounded(.up)
            if isExpanded {
                self.delegateOutputs?.getbuttonState(btnViewAllVisible: false, btnHideAllVisible: true)
            }else {
                if numOfRows > 2 {
                    self.delegateOutputs?.getbuttonState(btnViewAllVisible: true, btnHideAllVisible: false)
                }else {
                    self.delegateOutputs?.getbuttonState(btnViewAllVisible: false, btnHideAllVisible: false)
                }
            }
        }
    }
}

extension StoreMainCategoriesViewPresenter: StoreMainCategoriesViewInputs {
    func setInitialisers(grocery: Grocery, categories: [CategoryDTO]) {
        self.grocery = grocery
        self.categoryList = categories
        self.configure()
    }
    
    func categoryTapHandler(category: CategoryDTO) {
        self.delegate?.categoryTapHandler(category: category, categories: categoryList)
    }
    func viewHideAllCategories(isExpanded: Bool) {
        self.getCollectionViewHeight(cellViewModels: self.cellVMs, isExpanded: isExpanded)
        self.getButtonsState(isExpanded: isExpanded)
    }
}
