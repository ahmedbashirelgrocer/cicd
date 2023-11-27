//
//  RxCollectionViewOnlyTableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 26/11/2023.
//

import UIKit
import RxSwift
import RxDataSources



protocol RxCollectionViewOnlyTableViewCellInput { }

protocol RxCollectionViewOnlyTableViewCellOutput {
    var updateCellHeight: Observable<CGFloat> { get }
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
        }
    }
    private var viewModel: RxCollectionViewOnlyTableViewCellViewModel!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    //MARK: OutPut
    var updateCellHeight: Observable<CGFloat>  { updateCellHeightSubject.asObservable() }
    //MARK: Subject
    private let updateCellHeightSubject = BehaviorSubject<CGFloat>(value: .leastNormalMagnitude)
  
    
    
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
  
       // Optional: Override intrinsicContentSize in your UICollectionViewCell subclass
    override var intrinsicContentSize: CGSize {
            self.layoutIfNeeded()
           return productsCollectionView.contentSize
    }
    
    private func registerCells() {
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.productsCollectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let nextCellNib = UINib(nibName: "NextCell", bundle: Bundle.resource)
        self.productsCollectionView.register(nextCellNib, forCellWithReuseIdentifier: kNextCellIdentifier)
        
        let productSekeltonCelllNib = UINib(nibName: "ProductSekeltonCell", bundle: Bundle.resource)
        self.productsCollectionView.register(productSekeltonCelllNib, forCellWithReuseIdentifier: kProductSekeltonCellIdentifier)
    }
    
    private func bindViews() {
        
        self.dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.productCollectionCellViewModels
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
            CellSelectionState.shared.inputs.selectProductWithID.onNext("")
            let offSetX = self.productsCollectionView.contentOffset.x
            let contentWidth = self.productsCollectionView.contentSize.width
            if offSetX > (contentWidth - self.productsCollectionView.frame.size.width - 200) {
                self.viewModel.fetchProductsObserver.onNext(())
            }
        }.disposed(by: disposeBag)
        
        viewModel.productCount.subscribe(onNext: { [weak self] productCount in
            guard let self = self else { return }
            updateCollectionViewHeight(productCount)
            self.setNeedsLayout()
            self.layoutIfNeeded()
            //self.updateCellHeightSubject.onNext(self.collectionViewHeight.constant)
        }).disposed(by: disposeBag)
        
        
//        productsCollectionView.rx.contentSize
//                   .subscribe(onNext: { [weak self] contentSize in
//                       // Update the height constraint of the cell based on the content size of the collection view
//                       self?.cellHeight.constant = contentSize.height
//                   })
//                   .disposed(by: disposeBag)
        
    }
    
    func updateCollectionViewHeight(_ productCount : Int) {
            productsCollectionView.collectionViewLayout.invalidateLayout()
            //let newHeight = productsCollectionView.contentSize.height
            cellHeight.constant = (CGFloat(productCount/2) * (kProductCellHeight + 20) )
            self.invalidateIntrinsicContentSize()
             //layoutIfNeeded()
        }
    
}


extension RxCollectionViewOnlyTableViewCell: UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGSize = CGSize(width: kProductCellWidth, height: kProductCellHeight)
        return cellSize
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
    // Parent
    // MARK: Subject
    private let fetchProductsSubject = PublishSubject<Void>()
    private var refreshProductCellSubject = PublishSubject<Void>()
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
    private var isLoading = false
    
  

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
        self.productCountSubject.onNext(1)
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
            
            let pageNumber = self.offset / self.limit
            
            guard self.category?.algoliaQuery == nil else {
                if let query = self.category?.algoliaQuery {
                    ProductBrowser.shared.searchWithQuery(query:query, pageNumber: pageNumber, ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStorePage ?? 20) { [weak self] content, error in
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
        
        DispatchQueue.global(qos: .utility).async(execute: self.dispatchWorkItem!)
    }
    
    func handleAlgoliaSuccessResponse(response products: (products: [Product], algoliaCount: Int?)) {
        // let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)

        self.moreAvailable = (products.algoliaCount ?? products.products.count) >= self.limit
        let cellVMs = products.products.map { product -> ProductCellViewModel in
            let vm = ProductCellViewModel(product: ProductDTO(product: product), grocery: self.grocery)
            refreshProductCellSubject.asObservable().bind(to: vm.inputs.refreshDataObserver).disposed(by: disposeBag)
            return vm
        }
        
        if products.algoliaCount == 0{
            debugPrint("")
        }
        
        // this check ensure that the first call products is zero
//        if offset == 0 {
//            self.productCountSubject.onNext(products.algoliaCount ?? products.products.count)
//        }
        
        self.productCellVMs.append(contentsOf: cellVMs)
        self.isLoading = false
        self.productCollectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: self.productCellVMs)])
        self.offset += limit
        self.productCountSubject.onNext(self.productCellVMs.count)
        
        
    }
}
