//
//  StoreBuyItAgainViewPresenter.swift
//  
//
//  Created by saboor Khan on 14/05/2024.
//

import UIKit

protocol StoreBuyItAgainViewInputs: AnyObject {
    // internal use
    func setInitialisers(products: [ProductDTO])
    func viewAllTapHandler()
}

protocol StoreBuyItAgainViewOutputs: AnyObject {
    //Data sets
    func getCellViewModels(_ value: [[StoreBuyItAgainCollectionViewCellPresenter]])
    func getCollectionViewHeight(height: CGFloat)
    func getCollectionCellSize(size: CGSize)
}

protocol StoreBuyItAgainViewDelegate: AnyObject {
    //Navigations
    func buyItAgainviewAllTapHandler()
}

extension StoreBuyItAgainViewDelegate {
    func buyItAgainviewAllTapHandler() { }
}

protocol StoreBuyItAgainViewType {
    var inputs: StoreBuyItAgainViewInputs? { get }
    var delegateOutputs: StoreBuyItAgainViewOutputs? { get set }
    var delegate: StoreBuyItAgainViewDelegate? { get set }
}

class StoreBuyItAgainViewPresenter: StoreBuyItAgainViewType {
    
    //inputs
    var productArray: [ProductDTO] = []
    
    weak var inputs: StoreBuyItAgainViewInputs? { self }
    weak var delegateOutputs: StoreBuyItAgainViewOutputs?
    weak var delegate: StoreBuyItAgainViewDelegate?
    
    init(delegate: StoreBuyItAgainViewDelegate?) {
        self.delegate = delegate
    }
    
    func configure() {
        var cellViewModels: [[ReusableTableViewCellPresenterType]] = []
        var presenters: [StoreBuyItAgainCollectionViewCellPresenter] = []
        
        for product in productArray {
            let image = product.imageURL
            let vm = StoreBuyItAgainCollectionViewCellPresenter(imageUrl: image ?? "")
            presenters.append(vm)
        }
        
        cellViewModels.append(presenters)
        
        let cellSize = self.getCellSize()
        self.getCollectionViewHeight(cellViewModels: cellViewModels)
        self.delegateOutputs?.getCollectionCellSize(size: cellSize)
        self.delegateOutputs?.getCellViewModels(cellViewModels as! [[StoreBuyItAgainCollectionViewCellPresenter]])
    }
    
    private func getCellSize()-> CGSize {
        let cellSpacing: CGFloat = 24
        let paddingInside: CGFloat = 32 // left right
        let paddingOutside: CGFloat = 32 // left right
        let screenWidth = ScreenSize.SCREEN_WIDTH - ((cellSpacing) + (paddingInside) + (paddingOutside))
        let finalWidth = screenWidth / 4
        return CGSize(width: finalWidth, height: finalWidth)
    }
    
    private func getCollectionViewHeight(cellViewModels: [[ReusableTableViewCellPresenterType]]) {
        guard let vms = cellViewModels.first as? [StoreBuyItAgainCollectionViewCellPresenter] else {return}
        
        let singleRowHeight = Double(getCellSize().height)
        let numOfRows = (vms.count > 4 && vms.count > 0) ? 2 : 1
        var paddingHeight: Double = 0
        var height: Double = 0
        if numOfRows > 1 {
            paddingHeight = Double((numOfRows - 1) * 8)
        }
        height = singleRowHeight * Double(numOfRows)
        self.delegateOutputs?.getCollectionViewHeight(height: CGFloat(height + paddingHeight))
    }
}

extension StoreBuyItAgainViewPresenter: StoreBuyItAgainViewInputs {
    func setInitialisers(products: [ProductDTO]) {
        self.productArray = products
        self.configure()
    }
    
    func viewAllTapHandler() {
        self.delegate?.buyItAgainviewAllTapHandler()
    }
    
    
}
