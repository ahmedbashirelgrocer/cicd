//
//  CategorySelectionBottomSheetViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 13/08/2023.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class CategorySelectionBottomSheetViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                collectionView.semanticContentAttribute = .forceLeftToRight
            }
        }
    }
    
    private var viewModel: CategorySelectionViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    private var disposeBag = DisposeBag()
    
    var categorySelected: ((CategoryDTO)->())?
    
    static func make(viewModel: CategorySelectionViewModelType) -> CategorySelectionBottomSheetViewController {
        let vc = CategorySelectionBottomSheetViewController(nibName: "CategorySelectionBottomSheetViewController", bundle: .resource)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViews()
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

fileprivate extension CategorySelectionBottomSheetViewController {
    func setupViews() {
        
        self.collectionView.register(UINib(nibName: StoresCategoriesCollectionViewCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: StoresCategoriesCollectionViewCell.defaultIdentifier)
        
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 80) / 3, height: 110)
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            let edgeInset:CGFloat =  16
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
    }
    
    func bindViews() {
        self.dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { _, collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        self.viewModel.outputs.categoriesDataSource
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.collectionView.rx.modelSelected(StoresCategoriesCollectionViewCellViewModel.self)
            .map { $0.category }
            .subscribe(onNext: { [weak self] in
                if let categorySelected = self?.categorySelected {
                    categorySelected($0)
                }
            }).disposed(by: disposeBag)
    }
}
