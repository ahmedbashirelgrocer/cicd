//
//  RxCollectionViewOnlyTableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 26/11/2023.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa



protocol RxCollectionViewOnlyTableViewCellInput { }

protocol RxCollectionViewOnlyTableViewCellOutput {
    var updateCellHeight: Observable<CGFloat> { get }
    var basketUpdated: Observable<Void> { get }
}

protocol RxCollectionViewOnlyTableViewCellType: RxCollectionViewOnlyTableViewCellOutput, RxCollectionViewOnlyTableViewCellInput {
    var inputs: RxCollectionViewOnlyTableViewCellInput { get }
    var outputs: RxCollectionViewOnlyTableViewCellOutput { get }
}

extension RxCollectionViewOnlyTableViewCellType {
    var inputs: RxCollectionViewOnlyTableViewCellInput { self }
    var outputs: RxCollectionViewOnlyTableViewCellOutput { self }
}


class RxCollectionViewOnlyTableViewCell: RxUITableViewCell {
    
    @IBOutlet weak var productsCollectionView: TouchlessCollectionView! {
        didSet {
            productsCollectionView.backgroundColor = .white
            productsCollectionView.delegate = self
            productsCollectionView.isScrollEnabled = false
            productsCollectionView.bounces = true
//            productsCollectionView.isPagingEnabled = true
        }
    }

    var viewModel: RxCollectionViewOnlyTableViewCellViewModel!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    //MARK: OutPut
    var updateCellHeight: Observable<CGFloat>  { updateCellHeightSubject.asObservable() }
    var basketUpdated: Observable<Void> { basketUpdatedSubject.asObservable() }
    //MARK: Subject
    private let updateCellHeightSubject = BehaviorSubject<CGFloat>(value: .leastNormalMagnitude)
    private let basketUpdatedSubject = PublishSubject<Void>()
   
    private var lastUpdateProductCount = 0
    private var isViewBinded: Bool = false
    
    
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        registerCells()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func configure(viewModel: Any) {
        
        guard let viewModel = viewModel as? RxCollectionViewOnlyTableViewCellViewModel else { return }
        self.viewModel = viewModel
        bindViews()
    }
  
    private func registerCells() {
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.productsCollectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let nextCellNib = UINib(nibName: "NextCell", bundle: Bundle.resource)
        self.productsCollectionView.register(nextCellNib, forCellWithReuseIdentifier: kNextCellIdentifier)
        
        let productSekeltonCelllNib = UINib(nibName: "ProductSekeltonCell", bundle: Bundle.resource)
        self.productsCollectionView.register(productSekeltonCelllNib, forCellWithReuseIdentifier: kProductSekeltonCellIdentifier)
        
//        self.productsCollectionView.register(LoadMoreFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadMoreFooterView.identifier)
//               // Create an instance of LoadMoreFooterView
//        loadMoreFooterView = productsCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadMoreFooterView.identifier, for: IndexPath()) as? LoadMoreFooterView
//        loadMoreFooterView.delegate = self
       

    }
    
    override func bind(to subject: PublishSubject<(contentOffset: CGPoint, didScrollEvent: Void)>) {
            subject
                .subscribe(onNext: { [weak self] (contentOffset, _) in
                    guard let self = self else { return }
                    let offSetY = contentOffset.y + 250 + self.bounds.maxY
                    let contentHeight = self.productsCollectionView.contentSize.height - 200
                    if offSetY > ((contentHeight) - (self.productsCollectionView.frame.size.width)  ) {
                        self.viewModel.fetchProductsObserver.onNext(())
                    }
                })
                .disposed(by: disposeBag)
    }
    
    private func bindViews() {
        
        self.dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.productCollectionCellViewModels
            .do(onNext: { item in
               // self.updateCollectionViewHeight(item.first?.items.count ?? 0)
            })
            .bind(to: self.productsCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.outputs.isArabic.subscribe(onNext: { [weak self] isArbic in
            guard let self = self else { return }
            if isArbic {
                self.productsCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.productsCollectionView.semanticContentAttribute = .forceLeftToRight
            }
        }).disposed(by: disposeBag)
        
        // Pagination
        productsCollectionView.rx.didScroll.subscribe { [weak self] _ in
            guard let self = self else { return }
            let offSetX = self.productsCollectionView.contentOffset.x
            let contentWidth = self.productsCollectionView.contentSize.width
            if offSetX > (contentWidth - self.productsCollectionView.frame.size.width - 200) {
                // self.viewModel.fetchProductsObserver.onNext(())
            }
        }.disposed(by: disposeBag)
    
        /*
        productsCollectionView.rx.contentSize
            .subscribe(onNext: { [weak self] newSize in
                print("Collection view content size changed: \(newSize)")
//                guard let self = self else { return }
//                guard newSize.height > 0 else { return }
//                guard self.cellHeight.constant != newSize.height else { return }
//                productsCollectionView.layoutIfNeeded()
//                self.cellHeight.constant = newSize.height
//                //asdfasdfsd
               // self.getHeightChangeSubject().onNext((self,newSize))
            })
            .disposed(by: disposeBag)
        */
        
        viewModel.productCount
            .subscribe(onNext: { [weak self] productCount in
            guard let self = self else { return }
            // self.productCountValue = productCount
                updateCollectionViewHeight(productCount)
        }).disposed(by: disposeBag)
    }
    
    func updateCollectionViewHeight(_ productCount : Int) {
        guard productCount > 0, lastUpdateProductCount != productCount else {
            return
        }
        lastUpdateProductCount = productCount
        self.cellHeight.constant = productCount == 0 ? .leastNormalMagnitude : (CGFloat(ceil(Double(productCount) / 2)) * (kProductCellHeight + 12) + ( productCount % 2 == 0 ? 0 : 32) )
        DispatchQueue.main.async {
            self.updateTableViewWithSpringAnimation()
        }
    }
    
    private func updateTableViewWithSpringAnimation() {
        UIView.animate(
            withDuration: 0.5, // Adjust the duration as needed
            delay: 0.2,
            usingSpringWithDamping: 0.8, // Adjust the damping ratio as needed
            initialSpringVelocity: 0.5, // Adjust the initial velocity as needed
            options: .allowAnimatedContent, // Adjust the animation curve as needed
            animations: { [weak self] in
                (self?.superview as? UITableView)?.beginUpdates()
                (self?.superview as? UITableView)?.endUpdates()
            },
            completion:{ finished in
               
            })
    }
    
}

extension RxCollectionViewOnlyTableViewCell: UICollectionViewDelegateFlowLayout  {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: 44) // Adjust the height as needed
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionFooter {
//            return loadMoreFooterView
//        }
//        return UICollectionReusableView()
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 16
       // let collectionViewWidth = collectionView.bounds.width
        let totalSpacing = (3 * spacing) // 2 cells with spacing on each side // 16 extra to center spacing
        let itemWidth = (ScreenSize.SCREEN_WIDTH - totalSpacing) / 2
            return CGSize(width: itemWidth, height: kProductCellHeight)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: 16, left: 16 , bottom: 16 , right: 16)
    }
    
}


class RxCollectionViewOnlyTableViewCellViewModel: DynamicComponentContainerCellViewModel {
    
    // MARK: Inputs
    //var scrollObserver: AnyObserver<IndexPath> { self.scrollSubject.asObserver() }
    var fetchProductsObserver: AnyObserver<Void> { fetchProductsSubject.asObserver() }
    var refreshProductCellObserver: AnyObserver<Void> { refreshProductCellSubject.asObserver() }
    // MARK: Outputs
    var basketUpdated: Observable<Void> { basketUpdatedSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    // Parent
    // MARK: Subject
    private let fetchProductsSubject = PublishSubject<Void>()
    private var refreshProductCellSubject = PublishSubject<Void>()
    private let basketUpdatedSubject = PublishSubject<Void>()
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private var productCellVMs: [ProductCellViewModel] = []
    private var dispatchWorkItem: DispatchWorkItem?
    private var apiClient: ElGrocerApi?
    private var grocery: Grocery?
    private var deliveryTime: Int?
    private var category: CategoryDTO?
    private var offset = 0
    private var limit = ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStorePage ?? 20
    private var moreAvailable = true
    private var isLoading = false {
        didSet {
            self.loadingSubject.onNext(isLoading)
        }
    }
    var productCountValue = 0
  

    init(apiClient: ElGrocerApi = ElGrocerApi.sharedInstance, algoliaAPI: AlgoliaApi = AlgoliaApi.sharedInstance, deliveryTime: Int, category: CategoryDTO?, grocery: Grocery?, component: CampaignSection) {
        
        super.init(component: component)
        
        self.apiClient = apiClient
        self.deliveryTime = deliveryTime
        self.category = category
        self.grocery = grocery
       
        self.fetchProductsSubject.asObserver().subscribe(onNext: { [unowned self] category in
            guard let category = self.category else { return }
            if !self.isLoading && self.moreAvailable {
                self.fetchProduct(category: category)
                self.isLoading = true
            }
        }).disposed(by: disposeBag)
        self.fetchProductsSubject.onNext(())
       // self.productCountSubject.onNext(0)
    }
    
}
private extension RxCollectionViewOnlyTableViewCellViewModel {
    
    func fetchProduct(category: CategoryDTO) {
        guard let deliveryTime = deliveryTime else { return }
        
        self.dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            let parameters = NSMutableDictionary()
            parameters["limit"] = self.limit
            parameters["offset"] = self.offset
            parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
            parameters["category_id"] = category.id
            parameters["delivery_time"] =  deliveryTime
            parameters["shopper_id"] = UserDefaults.getLogInUserID()
            
            if let config = ElGrocerUtility.sharedInstance.appConfigData, config.fetchCatalogFromAlgolia == false, category.algoliaQuery == nil {
                ProductBrowser.shared.getTopSellingProductsOfGrocery(parameters, true) { result in
                    switch result {
                    case .success(let response):
                        self.handleAlgoliaSuccessResponse(response: response)
                        break
                    case .failure(_):
                        //    print("hanlde error >> \(error)")
                        break
                    }
                }
                return
            }
            
            let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
            self.limit = self.category?.algoliaQuery != nil ? 20 : self.limit
            
            let pageNumber = self.offset / self.limit
            // ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStorePage ?? 20
            guard self.category?.algoliaQuery == nil else {
                if let query = self.category?.algoliaQuery {
                   // guard self.offset < 21 else { return }
                    ProductBrowser.shared.searchWithQuery(query:query, pageNumber: pageNumber, self.limit) { [weak self] content, error in
                        if let _ = error {  return }
                        guard let response = content else { return }
                        self?.handleAlgoliaSuccessResponse(response: response)
                    }
                }
                return
            }
            
            guard category.id > 1 else {
                ProductBrowser.shared.searchOffersProductListForStoreCategory(storeID: storeId, pageNumber: pageNumber, hitsPerPage: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStorePage ?? 20, Int64(deliveryTime), slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsStorePage ?? 3) { [weak self] content, error in
                    if let _ = error {
                        //  print("handle error >>> \(error)")
                        return
                    }
                    guard let response = content else { return }
                    self?.handleAlgoliaSuccessResponse(response: response)
                    
                }
                return
            }
            
            ProductBrowser.shared.searchProductListForStoreCategory(storeID: storeId, pageNumber: pageNumber, categoryId: String(category.id), hitsPerPage: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStorePage ?? 20, slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsStorePage ?? 3) { [weak self] content, error in
                guard let self = self else { return }
                
                if let _ = error {
                    //  print("handle error >>> \(error)")
                    return
                }
                
                guard let response = content else { return }
                self.handleAlgoliaSuccessResponse(response: response)
            }
        }
        
        if self.offset == 0 {
            DispatchQueue.global(qos: .default).async(execute: self.dispatchWorkItem!)
        }else {
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2, execute: self.dispatchWorkItem!)
        }
        
    }
    
    func handleAlgoliaSuccessResponse(response products: (products: [Product], algoliaCount: Int?)) {
       

        self.moreAvailable = (products.algoliaCount ?? products.products.count) >= self.limit
        let cellVMs = products.products.map { product -> ProductCellViewModel in
            let vm = ProductCellViewModel(product: ProductDTO(product: product), grocery: self.grocery)
            vm.outputs.basketUpdated.bind(to: self.basketUpdatedSubject).disposed(by: self.disposeBag)
            refreshProductCellSubject.asObservable().bind(to: vm.inputs.refreshDataObserver).disposed(by: disposeBag)
            return vm
        }
        
      
        self.productCellVMs.append(contentsOf: cellVMs)
        self.isLoading = false
        self.productCollectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: self.productCellVMs)])
        self.offset += limit
        self.productCountSubject.onNext(self.productCellVMs.count)
        self.productCountValue = self.productCellVMs.count
        if self.productCellVMs.count >= 20 { self.moreAvailable = false } // check for custom marketing campaign page
      
    }
}


