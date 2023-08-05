//
//  CategoriesCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 13/01/2023.
//

import UIKit
import RxSwift
import RxDataSources

class CategoriesCell: RxUITableViewCell {
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            self.lblTitle.setH4SemiBoldStyle()
        }
    }
    @IBOutlet weak var contentBGView: UIView!
    @IBOutlet weak var topLabelBgView: UIView!
    @IBOutlet weak var btnViewAll: AWButton! {
        didSet {
            btnViewAll.setTitleColor(ApplicationTheme.currentTheme.buttonTextWithClearBGColor, for: UIControl.State())
            btnViewAll.setBackgroundColorForAllState(.clear)
        }
    }
    @IBOutlet weak var ivArrow: UIImageView! {
        didSet{
            if SDKManager.shared.isSmileSDK  {
                ivArrow.image = UIImage(name: "SettingArrowForward")
            }
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    
    private var varient: Bool = false
    
    private var viewModel: CategoriesCellViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.collectionView.register(UINib(nibName: StoresCategoriesCollectionViewCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: StoresCategoriesCollectionViewCell.defaultIdentifier)
        
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            
            layout.itemSize = self.calculateCellHeight()
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 12
            let edgeInset: CGFloat =  16
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: edgeInset / 2, right: edgeInset)
            return layout
        }()//16+
    }

    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? CategoriesCellViewModel else { return }
        
        self.viewModel = viewModel
        self.bindViews()
        self.setBgColors()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func calculateCellHeight() -> CGSize {
        if varient {
            return CGSize(width: (ScreenSize.SCREEN_WIDTH - 56) / 3, height: (ScreenSize.SCREEN_WIDTH - 56) / 3)
        }
        
        return CGSize(width: 75 , height: 108)
    }
    
    private func setBgColors() {
        
        var color = UIColor.clear //ApplicationTheme.currentTheme.StorePageCategoryViewBgColor
        collectionView.backgroundColor = color
        topLabelBgView.backgroundColor = color
        contentBGView.backgroundColor = color
    }
    
    @IBAction func viewAllTapped(_ sender: Any) {
        self.viewModel.viewAllObserver.onNext(())
    }
}

private extension CategoriesCell {
    func bindViews() {
        self.dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        self.viewModel
            .outputs
            .collectionCellViewModels
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.collectionView
            .rx
            .modelSelected(StoresCategoriesCollectionViewCellViewModel.self)
            .map { $0.category }
            .bind(to: self.viewModel.inputs.tapObserver)
            .disposed(by: disposeBag)
        
        self.viewModel
            .outputs
            .title
            .bind(to: self.lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .viewAllText
            .bind(to: self.btnViewAll.rx.title(for: UIControl.State()))
            .disposed(by: disposeBag)
        
        viewModel.outputs.isArbic.subscribe(onNext: { [weak self] isArbic in
            guard let self = self else { return }
            
            if isArbic {
                self.ivArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.collectionView.semanticContentAttribute = .forceLeftToRight
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.categoriesCount.subscribe(onNext: { [weak self] count in
            guard let self = self else { return }
            
            let singleRowLimit = 5
            let headerHeight = 61.0
            let baseVarientHeight = count > 5 ? 314 : 206.0
            let otherVarientHeight = (ScreenSize.SCREEN_WIDTH - 16) + headerHeight
            
            self.cellHeightConstraint.constant = self.varient ? otherVarientHeight : baseVarientHeight
            self.invalidateIntrinsicContentSize()
        }).disposed(by: disposeBag)
        
        
    }
}

extension CategoriesCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75 , height: 108)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 11, bottom: 4, right: 16)
    }
}

