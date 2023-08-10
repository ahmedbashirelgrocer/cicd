//
//  SubCategoryProductsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import UIKit
import RxSwift
import RxCocoa

class SubCategoryProductsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoriesSegmentedView: ILSegmentView!
    
    private var viewModel: SubCategoryProductsViewModelType!
    private var disposeBag = DisposeBag()
    
    static func make(viewModel: SubCategoryProductsViewModelType) -> SubCategoryProductsViewController {
        let vc = SubCategoryProductsViewController(nibName: "SubCategoryProductsViewController", bundle: .resource)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bindViews()
        
        self.navigationController?.navigationBar.isHidden = false
    }
}

fileprivate extension SubCategoryProductsViewController {
    func setupViews() {
        categoriesSegmentedView.selectionStyle = .wholeCellHighlight
    }
    
    func bindViews() {
        viewModel.outputs.categories
            .bind(to: categoriesSegmentedView.rx.categories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.selectedCategoryIndex
            .bind(to: categoriesSegmentedView.rx.selectedItemIndex)
            .disposed(by: disposeBag)
        
        categoriesSegmentedView
            .onTap { [weak self] index in
                self?.viewModel.inputs.categorySegmentTapObserver.onNext(index)
            }
    }
}
