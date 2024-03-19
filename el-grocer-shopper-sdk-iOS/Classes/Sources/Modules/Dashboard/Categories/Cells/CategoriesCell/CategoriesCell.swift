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
    
    
    @IBOutlet var btnViewAllBGView: AWView! {
        didSet {
            btnViewAllBGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 14.5)
            btnViewAllBGView.backgroundColor = ApplicationTheme.currentTheme.viewthemePrimaryBlackBGColor
        }
    }
    
    @IBOutlet weak var btnViewAll: AWButton! {
        didSet {
            btnViewAll.setTitleColor(ApplicationTheme.currentTheme.buttonthemeBaseBlackPrimaryForeGroundColor, for: UIControl.State())
            btnViewAll.setBackgroundColorForAllState(.clear)
            btnViewAll.titleLabel?.font = UIFont.SFProDisplayBoldFont(14)
        }
    }
    @IBOutlet weak var ivArrow: UIImageView! {
        didSet{
            //if SDKManager.shared.isSmileSDK  {
                ivArrow.image = UIImage(name: "arrowForwardSmiles")
            //}
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dividerHeightConstraint: NSLayoutConstraint!
    
    private var categoriesStyle = ABTestManager.shared.storeConfigs.categoriesStyle
    
    private var viewModel: CategoriesCellViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.collectionView.register(UINib(nibName: StoresCategoriesCollectionViewCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: StoresCategoriesCollectionViewCell.defaultIdentifier)
        
        self.collectionView.isScrollEnabled = categoriesStyle == .horizotalScroll
        self.collectionView.bounces = false
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = categoriesStyle == .horizotalScroll ? .horizontal : .vertical
            layout.itemSize = self.calculateCellHeight()
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 12
            let edgeInset: CGFloat =  16
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: edgeInset / 2, right: edgeInset)
            return layout
        }()//16+
        
        // hides separator for varient than baseline
        self.dividerHeightConstraint.constant = categoriesStyle == .horizotalScroll ? 16 : 0
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
        switch categoriesStyle {
        case .horizotalScroll:
            return CGSize(width: 75 , height: 108)
            
        case .verticalScroll:
            return CGSize(width: (ScreenSize.SCREEN_WIDTH - 56) / 3, height: 136)
        }
    }
    
    private func setBgColors() {
        
        let color = UIColor.clear //ApplicationTheme.currentTheme.StorePageCategoryViewBgColor
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
        
        // hide View All button for varient other than base
        self.btnViewAll.isHidden = self.categoriesStyle == .verticalScroll
        self.btnViewAllBGView.isHidden = self.categoriesStyle == .verticalScroll
        self.ivArrow.isHidden = self.categoriesStyle == .verticalScroll
        
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
        
        viewModel.outputs.categoriesCount.subscribe(onNext: { [weak self] categoriesCount in
            guard let self = self else { return }

            let headerHeight = 45.0
            let cellHeight = 136.0
            let rows = categoriesCount % 3 == 0 ? categoriesCount / 3 : (categoriesCount / 3) + 1
            let cellMargin = Double(rows * 12) + 8
            
            let otherVarientHeight = (cellHeight * Double(rows)) + cellMargin + headerHeight
            let baseVarientHeight = categoriesCount > 5 ? 314 : 206.0
            
            self.cellHeightConstraint.constant = self.categoriesStyle == .horizotalScroll ? baseVarientHeight : otherVarientHeight
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

