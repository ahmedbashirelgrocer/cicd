//
//  HomeCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 07/05/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import Shimmer
import SDWebImage
import RxSwift
import RxDataSources

// import PMAlertController
let kHomeCellIdentifier = "HomeCell"
let kHomeCellHeight: CGFloat = 340


protocol HomeCellDelegate: class {
    
    func productCellOnProductQuickAddButtonClick(_ selectedProduct:Product, homeObj: Home, collectionVeiw:UICollectionView)
    
    func productCellOnProductQuickRemoveButtonClick(_ selectedProduct:Product, homeObj: Home, collectionVeiw:UICollectionView)
    
    func productCellChooseReplacementButtonClick(_ product: Product)
    
    func navigateToProductsView(_ homeObj: Home)
    
    func navigateToCategories(_ categoryA: [Category])
    
    func navigateToSubCategoryFrom( category: Category)
    
    func navigateToGrocery(_ grocery: Grocery? , homeFeed: Home? )
}
extension HomeCellDelegate {
    func navigateToCategories(_ categoryA: [Category]) {}
    func navigateToSubCategoryFrom( category: Category) {}
    func navigateToGrocery(_ grocery: Grocery? , homeFeed: Home? ) {}
}

class HomeCell: RxUITableViewCell {
    override func configure(viewModel: Any) {
        let viewModel = viewModel as! HomeCellViewModelType
        
        self.dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        self.productsCollectionView.dataSource = nil
        viewModel.outputs.productCollectionCellViewModels.bind(to: self.productsCollectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        viewModel.outputs.title.bind(to: self.titleLbl.rx.text).disposed(by: disposeBag)
    }
    
    @IBOutlet weak var rightArrowImageView: UIImageView!
    // @IBOutlet weak var arrowImgView: UIImageView!
    @IBOutlet weak var viewMoreButton: UIButton! {
        didSet {
            viewMoreButton.setTitleColor(ApplicationTheme.currentTheme.buttonTextWithClearBGColor, for: UIControl.State())
            viewMoreButton.setBackgroundColorForAllState(.clear)
        }
    }
    @IBOutlet weak var titleLbl: UILabel!{
        didSet{
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    titleLbl.textAlignment = .right
                }else{
                    titleLbl.textAlignment = .left
                }
            }
        }
    }
    @IBOutlet weak var titleShimmerView: FBShimmeringView!
    @IBOutlet weak var productsCollectionView: UICollectionView!{
        didSet{
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    self.productsCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                    productsCollectionView.semanticContentAttribute = .forceRightToLeft
                }else{
                    productsCollectionView.semanticContentAttribute = .forceLeftToRight
                }
            }
        }    }
    
    @IBOutlet weak var titleViewHeight: NSLayoutConstraint!
    @IBOutlet var cellTopSpace: NSLayoutConstraint!
    @IBOutlet var topDistanceOfTitle: NSLayoutConstraint!
    
    
    @IBOutlet var imgViewWidth: NSLayoutConstraint!
    @IBOutlet var titleLeftSpacing: NSLayoutConstraint!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var rightButtonWidth: NSLayoutConstraint!
    
    
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    private weak var homeFeed: Home?
    private weak var grocery:Grocery?
    
    weak var delegate:HomeCellDelegate?
    
    //Products Pagnation variables
    var currentOffset = 0
    var currentLimit = 5

    var isGettingProducts = false
    var isNeedToShowRecipe = false
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setArrowAppearance()
        
        let storeCateCell = UINib(nibName: KStoresCategoriesCollectionViewCell , bundle: Bundle.resource)
        self.productsCollectionView.register(storeCateCell, forCellWithReuseIdentifier: KStoresCategoriesCollectionViewCell)
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.productsCollectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let nextCellNib = UINib(nibName: "NextCell", bundle: Bundle.resource)
        self.productsCollectionView.register(nextCellNib, forCellWithReuseIdentifier: kNextCellIdentifier)
        
        let productSekeltonCelllNib = UINib(nibName: "ProductSekeltonCell", bundle: Bundle.resource)
        self.productsCollectionView.register(productSekeltonCelllNib, forCellWithReuseIdentifier: kProductSekeltonCellIdentifier)
        
       // let arrowIcon = ElGrocerUtility.sharedInstance.getImageWithName("Disclosure Arrow")
//        self.arrowImgView.image = arrowIcon
//        self.arrowImgView.image = self.arrowImgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
//        self.arrowImgView.tintColor = UIColor.colorWithHexString(hexString: "b7becf")
        
        //self.titleLbl.textColor =  UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        //self.titleLbl.font = UIFont.SFProDisplayBoldFont(20)
        self.titleLbl.setH4SemiBoldStyle()
    }
    
    func setArrowAppearance(){
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.rightArrowImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func setStateWithImageView() {
        
        
        
        self.imgViewWidth.constant = 40
        self.titleLeftSpacing.constant = 12
        self.rightButtonWidth.constant = 103-10
    }
    
    func setStateWithOutImageView() {
        self.imgViewWidth.constant = 0
        self.titleLeftSpacing.constant = 0
        self.rightButtonWidth.constant = 80-10
    }
    
    func configureCell(_ homeFeed: Home?, grocery:Grocery? , _ isNeedToShowRecipe : Bool = false){
        
        self.homeFeed = nil
        self.viewMoreButton.isHidden = true
        rightArrowImageView.isHidden = true
       // self.arrowImgView.isHidden = true
       
        if let homeFeedObj = homeFeed {
            
            
            if homeFeedObj.type == HomeType.universalSearchProducts {
                self.setStateWithImageView()
                self.setImageData(homeFeed: homeFeedObj)
            }else{
                self.setStateWithOutImageView()
            }
            
            self.grocery = grocery
            self.homeFeed = homeFeedObj
            self.titleLbl.text = homeFeedObj.title
            self.titleLbl.backgroundColor = UIColor.clear
            
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                self.productsCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.productsCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
            
            self.titleShimmerView.isShimmering = false
           
            
            if  self.homeFeed?.type == .ListOfCategories {
                 self.cellTopSpace.constant = 0
                 self.titleViewHeight.constant = 45
                 self.topDistanceOfTitle.constant = 9
                 self.viewMoreButton.setTitle(localizedString("view_more_title", comment: ""), for: UIControl.State())
                 self.viewMoreButton.isHidden = false
                rightArrowImageView.isHidden = false
                 self.isNeedToShowRecipe = isNeedToShowRecipe
            }else{
                self.topDistanceOfTitle.constant = 0
                self.titleViewHeight.constant = 27
                self.cellTopSpace.constant = 17
                
                self.viewMoreButton.setTitle( (homeFeedObj.type == HomeType.universalSearchProducts ) ? localizedString("lbl_goToStore", comment: "").uppercased() : localizedString("view_more_title", comment: ""), for: UIControl.State())
                self.viewMoreButton.isHidden = false
                rightArrowImageView.isHidden = false
                homeFeedObj.products.sort { (productOne, productTwo) -> Bool in
                    return productOne.isAvailable > productTwo.isAvailable
                }
            }
            
           
        }else{
            
            self.titleViewHeight.constant = 10.0
            self.titleLbl.text = ""
            self.titleLbl.backgroundColor = UIColor.borderGrayColor()
            self.titleShimmerView.contentView = self.titleLbl
            self.titleShimmerView.isShimmering = true
        }
        
        if UIDevice.isIOS12() {
            UIView.performWithoutAnimation {
                self.productsCollectionView.reloadData()
                Thread.OnMainThread {
                    self.productsCollectionView.setContentOffset(CGPoint.zero, animated:false)
                }
            }
            
        }else{
            UIView.performWithoutAnimation {
                Thread.OnMainThread {
                    self.productsCollectionView.reloadData()
                    self.productsCollectionView.setContentOffset(CGPoint.zero, animated:false)
                }
                
            }
        }
        
        
    
       
        
    }
    
    
    func setImageData (homeFeed: Home) {

        
        let urlString = homeFeed.attachGrocery?.smallImageUrl
        
        guard urlString != nil , urlString?.range(of: "http") != nil else {
            return
        }
        
        self.leftImageView.layer.cornerRadius = 8
        self.leftImageView.clipsToBounds = true
        
        self.leftImageView.sd_setImage(with: URL(string: urlString!), placeholderImage: nil, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
            guard let self = self else {
                return
            }
            if cacheType == SDImageCacheType.none {
                
                UIView.transition(with: self.leftImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                    guard let self = self else {
                        return
                    }
                    guard image != nil else {return}
                    self.leftImageView.image = image
                }, completion: nil)
            }
        })
     
    }
    

    
    @IBAction func viewMoreHandler(_ sender: Any) {
        if let homeFeed =  self.homeFeed {
            FireBaseEventsLogger.trackViewMoreClick(["Name" : homeFeed.title])
            if homeFeed.type == .ListOfCategories {
                MixpanelEventLogger.trackStoreCategoryClick(categoryId: "-1", categoryName: "View All")
                self.delegate?.navigateToCategories(homeFeed.categories)
            }else if homeFeed.type == .universalSearchProducts {
                self.delegate?.navigateToGrocery(homeFeed.attachGrocery, homeFeed: self.homeFeed)
            }else{
                 self.delegate?.navigateToProductsView(homeFeed)
            }
        }
    }
    
    private func getTopSellingProductsFromServer(_ homeObj: Home){
        
        self.isGettingProducts = true
        
        self.currentOffset += self.currentLimit
        
        let parameters = NSMutableDictionary()
        parameters["limit"] = 5
        parameters["offset"] = self.currentOffset
        parameters["retailer_id"] = self.grocery?.dbID
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
        parameters["delivery_time"] = time
        
        if homeObj.type == HomeType.Trending {
            parameters["is_trending"] = true
        }
        
        if homeObj.type == HomeType.Purchased {
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        
        if homeObj.type == HomeType.Category {
            parameters["category_id"] = homeObj.category?.dbID
        }
        
        ElGrocerApi.sharedInstance.getTopSellingProductsOfGrocery(parameters) { (result) in
            
            switch result {
                
            case .success(let response):
                self.saveResponseData(response, andWithHomeFeed: homeObj)
                
            case .failure(let error):
               elDebugPrint("Error While Calling Top Selling Pagination:%@",error.localizedMessage)
            }
        }
    }
    
    // MARK: Data
    
    func saveResponseData(_ responseObject:NSDictionary, andWithHomeFeed homeObj: Home) {
        
       // let dataDict = responseObject["data"] as! NSDictionary
        
        //Parsing All Products Response here
        let responseObjects = responseObject["data"] as! [NSDictionary]
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
            context.performAndWait({ () -> Void in
                let newProducts = Product.insertOrReplaceSixProductsFromDictionary(responseObjects as NSArray, context: context)
               elDebugPrint("New Products Count:%d",newProducts.count)
                homeObj.products += newProducts
            })
            
            DispatchQueue.main.async {
                self.isGettingProducts = false
                self.productsCollectionView.reloadData()
            }
        }
    }
}

extension HomeCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var rows = 3
        if let tempHomeFeed = self.homeFeed {
            rows  = tempHomeFeed.products.count + 1
            if tempHomeFeed.type == .ListOfCategories {
                rows  = tempHomeFeed.categories.count + ( self.isNeedToShowRecipe ? 1 : 0)
            }
            if tempHomeFeed.type == .universalSearchProducts {
                rows  = tempHomeFeed.products.count
            }
        }
        return rows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let homeFeedObj = self.homeFeed {
       
            if homeFeedObj.type == .ListOfCategories {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KStoresCategoriesCollectionViewCell, for: indexPath) as! StoresCategoriesCollectionViewCell
                var index = indexPath.row
                if indexPath.row == 0 && self.isNeedToShowRecipe {
                    cell.configuredRecipeCell()
                    return cell
                }
                if self.isNeedToShowRecipe {
                    index = index - 1
                }
                if homeFeedObj.categories.count > 0 {
                     cell.configuredCategoryCell (type: homeFeedObj.categories[index])
                    let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                    if currentLang == "ar" {
                        cell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
                    }
                    return cell
                }
                cell.configuredempty()
                return cell
            }else{
                
                if indexPath.row == homeFeedObj.products.count {

                    let nextCell = collectionView.dequeueReusableCell(withReuseIdentifier: kNextCellIdentifier, for: indexPath) as! NextCell
                    nextCell.configureCell()
                    return nextCell

                }
                
                let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
                let product =  homeFeedObj.products[indexPath.row]
                productCell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
                productCell.delegate = self
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    productCell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
                if homeFeedObj.type == .universalSearchProducts {
                    productCell.addToCartButton.setTitle(localizedString("lbl_ShopInStore", comment: ""), for: .normal)
                    productCell.addToCartButton.tintColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                    productCell.addToCartButton.isEnabled = true
                    productCell.addToCartButton.setBody3BoldWhiteStyle()
                    productCell.addToCartButton.setBackgroundColorForAllState(ApplicationTheme.currentTheme.buttonEnableBGColor)
                    productCell.productPriceLabel.isHidden = true
                    productCell.addToCartBottomPossitionConstraint.constant = CGFloat(productCell.topAddButtonmaxY)
                    productCell.addToCartButton.isHidden = false
                    productCell.buttonsView.isHidden = true
                    productCell.promotionBGView.isHidden = true
                    productCell.limitedStockBGView.isHidden = true
                    productCell.saleView.isHidden = true
                }else{
                    productCell.productPriceLabel.isHidden = false
                }
               
                return productCell
                
            }
            
            
            
        }else{
            
            let productSekeltonCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductSekeltonCellIdentifier, for: indexPath) as! ProductSekeltonCell
            productSekeltonCell.configureSekeltonCell()
            return productSekeltonCell
        }
    }
}

extension HomeCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let homeFeedObj = self.homeFeed {
            if homeFeedObj.type == .ListOfCategories {
                
                
                
                var index = indexPath.row
                if indexPath.row == 0 && self.isNeedToShowRecipe {
                    ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: FireBaseScreenName.Home.rawValue)
                    MixpanelEventLogger.trackStoreCategoryClick(categoryId: "recipe", categoryName: "-1")
                    let recipeStory = ElGrocerViewControllers.recipesBoutiqueListVC()
                    recipeStory.isNeedToShowCrossIcon = true
                    let grocerA : [Grocery] =  [self.grocery!]
                    recipeStory.groceryA = grocerA
                    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navigationController.hideSeparationLine()
                    navigationController.viewControllers = [recipeStory]
                    navigationController.modalPresentationStyle = .fullScreen
                    if let topVc = UIApplication.topViewController() {
                        topVc.navigationController?.present(navigationController, animated: true, completion: { });
                    }
                   return
                }
                if self.isNeedToShowRecipe {
                    index = index - 1
                }
                
                if index < homeFeedObj.categories.count {
                
                    let cate =  homeFeedObj.categories[index] as Category
                    
                      if cate.isPg18.boolValue && !UserDefaults.isUserOver18() {
                        
                        
                        if let SDKManager = UIApplication.shared.delegate {
                            let alertView = TobbacoPopup.showNotificationPopup(topView: (SDKManager.window ?? UIApplication.topViewController()?.view)!, msg: ElGrocerUtility.sharedInstance.appConfigData.pg_18_msg , buttonOneText: localizedString("over_18", comment: "") , buttonTwoText: localizedString("less_over_18", comment: ""))
                            
                            alertView.TobbacobuttonClickCallback = { [weak self] (buttonIndex) in
                                guard self == self  else {
                                    return
                                }
                                if buttonIndex == 0 {
                                    UserDefaults.setOver18(true)
                                    self?.delegate?.navigateToSubCategoryFrom(category: homeFeedObj.categories[index])
                                   
                                    return
                                }
                                UserDefaults.setOver18(false)
                               
                            }
                        }
                        
                    }else{
                        self.delegate?.navigateToSubCategoryFrom(category: homeFeedObj.categories[index])
                    }
                    return
                }
            }
            if indexPath.row == homeFeedObj.products.count {
                self.delegate?.navigateToProductsView(homeFeedObj)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let homeFeedObj = self.homeFeed {
            if homeFeedObj.type == .ListOfCategories {
                return 13
            }
        }
        return 0
    }
}

extension HomeCell: UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // create a cell size from the image size, and return the size
        let height = kProductCellHeight
        var cellSize:CGSize = CGSize(width: kProductCellWidth, height: height)
        if let homeFeedObj = self.homeFeed {
            if homeFeedObj.type == .ListOfCategories {
                cellSize = CGSize(width: 75 , height: 108)
            }else if indexPath.row == homeFeedObj.products.count {
                cellSize = CGSize(width: 60, height: height)
            }
        }
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        return cellSize
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if let homeFeedObj = self.homeFeed {
            if homeFeedObj.type == .ListOfCategories {
                 return UIEdgeInsets(top: 0, left: 11 , bottom: 0 , right: 16)
            }
        }
         return UIEdgeInsets(top: -5, left: 8 , bottom: 0 , right: 16)
    }
    
    
    
}

extension HomeCell: ProductCellProtocol {
    
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell, product: Product) {
        self.delegate?.productCellOnProductQuickAddButtonClick(product, homeObj: homeFeed!, collectionVeiw: self.productsCollectionView)
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell:ProductCell, product:Product){
        self.delegate?.productCellOnProductQuickRemoveButtonClick(product, homeObj: homeFeed!, collectionVeiw: self.productsCollectionView)
    }
    
    func chooseReplacementWithProduct(_ product: Product) {
        self.delegate?.productCellChooseReplacementButtonClick(product)
    }
    
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
       elDebugPrint("Product Favourite Click Handler")
    }
}
