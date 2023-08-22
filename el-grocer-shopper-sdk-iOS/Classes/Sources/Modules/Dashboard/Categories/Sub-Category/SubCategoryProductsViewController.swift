//
//  SubCategoryProductsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import STPopup

class SubCategoryProductsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subCategoriesSegmentedView: AWSegmentView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var buttonChangeCategory: AWButton!
    
    private lazy var locationHeaderShopper: ElGrocerStoreHeaderShopper = {
        let locationHeader = ElGrocerStoreHeaderShopper.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return locationHeader!
    }()
    private lazy var categoriesSegmentedView: ILSegmentView = {
        let view = ILSegmentView(scrollDirection: self.abTestVarient == .vertical ? .vertical : .horizontal)
        view.onTap { [weak self] category in
            self?.viewModel.inputs.categorySwitchObserver.onNext(category)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var bannerView: BannerView = {
        let view = BannerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: SubCategoryProductsViewModelType!
    private var abTestVarient: StoreConfigs.Varient = ABTestManager.shared.storeConfigs.variant
    private var disposeBag = DisposeBag()
    private var cellViewModels: [ReusableCollectionViewCellViewModelType] = []
    private var effectiveOffset: CGFloat = 0
    private var offset: CGFloat = 0 {
        didSet {
            let diff = offset - oldValue
            if diff > 0 { effectiveOffset = min(60, effectiveOffset + diff) }
            else { effectiveOffset = max(0, effectiveOffset + diff) }
        }
    }
    
    static func make(viewModel: SubCategoryProductsViewModelType) -> SubCategoryProductsViewController {
        let vc = SubCategoryProductsViewController(nibName: "SubCategoryProductsViewController", bundle: .resource)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraint()
        bindViews()
        
        self.basketIconOverlay
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func showCategoriesBottomSheet(_ sender: Any) {
        self.viewModel.inputs.categoriesButtonTapObserver.onNext(())
    }
}

private extension SubCategoryProductsViewController {
    func setupViews() {
        self.view.addSubview(self.bannerView)
        if self.abTestVarient != .bottomSheet {
            self.view.addSubview(self.categoriesSegmentedView)
        }
        
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
            self.locationHeaderShopper.configuredLocationAndGrocey(self.viewModel.grocery)
            self.locationHeaderShopper.setSlotData()
        } else {
            // add SDK header
        }
        
        subCategoriesSegmentedView.segmentViewType = .subCategories
        subCategoriesSegmentedView.commonInit()
        subCategoriesSegmentedView.segmentDelegate = self
        
        self.collectionView.register(UINib(nibName: ProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ProductCell.defaultIdentifier)
        
        var itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 22) / 2, height: 264)
        if abTestVarient == .vertical {
            itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 106) / 2, height: 237)
        }
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            let edgeInset:CGFloat =  8
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func setupConstraint() {
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
            locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            locationHeaderShopper.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            locationHeaderShopper.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
        } else {

        }
        
        switch self.abTestVarient {
            
        case .vertical:
            buttonChangeCategory.isHidden = true
            contentViewLeadingConstraint.isActive = false
            
            categoriesSegmentedView.topAnchor.constraint(equalTo: self.bannerView.bottomAnchor, constant: 8.0).isActive = true
            categoriesSegmentedView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4).isActive = true
            categoriesSegmentedView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.bannerView.topAnchor, constant: -8).isActive = true
            
            contentView.leftAnchor.constraint(equalTo: categoriesSegmentedView.rightAnchor).isActive = true
            bannerView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
        case .horizontal:
            buttonChangeCategory.isHidden = true
            categoriesSegmentedView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            categoriesSegmentedView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            categoriesSegmentedView.heightAnchor.constraint(equalToConstant: 114).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.bannerView.topAnchor, constant: -8).isActive = true
            bannerView.bottomAnchor.constraint(equalTo: self.categoriesSegmentedView.topAnchor).isActive = true
            

        case .bottomSheet:
            buttonChangeCategory.isHidden = false
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.bannerView.topAnchor, constant: -8).isActive = true
            bannerView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
        case .baseline: break
        }
        
        
        bannerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        bannerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
    }
    
    func bindViews() {
        viewModel.outputs.categories
            .bind(to: categoriesSegmentedView.rx.categories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.categorySwitch
            .bind(to: categoriesSegmentedView.rx.selectedItemIndex)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subCategories
            .bind(to: self.subCategoriesSegmentedView.rx.subCategories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subCategorySwitch
            .bind(to: self.subCategoriesSegmentedView.rx.selected)
            .disposed(by: disposeBag)
        
        viewModel.outputs.categoriesButtonTap.subscribe(onNext: { [weak self] in
            self?.showCategoriesBottomSheet(categories: $0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.title
            .bind(to: self.lblCategoryTitle.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.productCellViewModels
            .subscribe(onNext: { [weak self] viewModels in
                guard let self = self else { return }
                
                self.cellViewModels = viewModels
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        self.viewModel.outputs.loading
            .subscribe(onNext: { [weak self] loading in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if loading {
                        SpinnerView.showSpinnerView()
                    }else {
                        SpinnerView.hideSpinnerView()
                    }
                }
            }).disposed(by: disposeBag)
        
        viewModel.outputs.error
            .map { ElGrocerError(error: ($0 ?? ElGrocerError.genericError()) as NSError) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                error.showErrorAlert()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.banners
            .map { $0.map { $0.toBannerDTO() }}
            .bind(to: self.bannerView.rx.banners)
            .disposed(by: disposeBag)
        
        viewModel.outputs.banners
            .map { $0.isEmpty }
            .subscribe(onNext: { [weak self] isEmpty in
                DispatchQueue.main.async {
                    let height = isEmpty ? 0.0 : (ScreenSize.SCREEN_WIDTH - 32) / 2
                    
                    self?.bannerView.constraints.forEach { constraint in
                        if constraint.firstAttribute == .height {
                            constraint.constant = height
                        }
                    }
                    self?.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
    }
    
    func showCategoriesBottomSheet(categories: [CategoryDTO]) {
        let viewModel = CategorySelectionViewModel(categories: categories)
        let categoriesVC = CategorySelectionBottomSheetViewController.make(viewModel: viewModel)
        
        categoriesVC.categorySelected = { [weak self] category in
            self?.dismissPopUpVc()
            self?.lblCategoryTitle.text = category.name
            self?.viewModel.inputs.categorySwitchObserver.onNext(category)
        }
        
        categoriesVC.contentSizeInPopup = CGSizeMake(ScreenSize.SCREEN_WIDTH, CGFloat(ScreenSize.SCREEN_HEIGHT * 0.5))
        
        let popupController = STPopupController(rootViewController: categoriesVC)
        popupController.navigationBarHidden = true
        popupController.style = .bottomSheet
        popupController.backgroundView?.alpha = 1
        popupController.containerView.layer.cornerRadius = 12
        popupController.navigationBarHidden = true
        popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopUpVc)))
        popupController.present(in: self)
    }
    
    @objc func dismissPopUpVc() {
        self.dismiss(animated: true)
    }
}

extension SubCategoryProductsViewController: AWSegmentViewProtocol {
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex: Int) { }
    
    func subCategorySelectedWithSelectedCategory(_ selectedSubCategory: SubCategory) {
        self.viewModel.inputs.subCategorySwitchObserver.onNext(selectedSubCategory)
    }
}

extension SubCategoryProductsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = self.cellViewModels[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
        cell.configure(viewModel: viewModel)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cellHeight = self.abTestVarient == .vertical ? 237 : 264
        let rowsThreshold = CGFloat(4 * cellHeight)
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom

        if y  > scrollView.contentSize.height - rowsThreshold {
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
                self.viewModel.inputs.fetchMoreProducts.onNext(())
            }
        }
        
        offset = scrollView.contentOffset.y
        let value = min(effectiveOffset, scrollView.contentOffset.y)
        
        self.locationHeaderShopper.searchViewTopAnchor.constant = 62 - value
        self.locationHeaderShopper.searchViewLeftAnchor.constant = 16 + ((value / 60) * 30)
        self.locationHeaderShopper.groceryBGView.alpha = max(0, 1 - (value / 60))
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionHeader {
//            return self.bannerView
//        }
//        
//        return nil
//    }
}
