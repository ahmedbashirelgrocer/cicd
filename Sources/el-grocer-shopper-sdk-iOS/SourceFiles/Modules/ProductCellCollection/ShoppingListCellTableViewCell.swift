//
//  ShoppingListCellTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 16/02/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

protocol shoppingLisDelegate : class {


    func productCellOnFavouriteClick(_ productCell:ProductCell, product:Product) -> Void
    func productCellOnProductQuickAddButtonClick(_ productCell:ProductCell, product:Product) -> Void
    func productCellOnProductQuickRemoveButtonClick(_ productCell:ProductCell, product:Product) -> Void
    func chooseReplacementWithProduct(_ product:Product) -> Void
    func reloadCellIndexForBanner(_ currentIndex : Int , cell : ShoppingListCellTableViewCell) -> Void
    func addBannerFor(_ currentIndex : Int , searchResultString : String , homeFeed : Any?) -> Void


}

class ShoppingListCellTableViewCell: UITableViewCell ,UITextFieldDelegate {
     weak var delegate:shoppingLisDelegate?
    
    @IBOutlet weak var customCollectionView: CustomCollectionViewWithProducts!


    @IBOutlet weak var customCollectionViewWithBanner: CustomCollectionViewWithBanners! {

        didSet{
            customCollectionViewWithBanner.collectionView?.tag = -111021312
        }
    }

    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var NoItemFoundLable: UILabel!
    @IBOutlet weak var lblNoProductFound: UILabel!
    @IBOutlet weak var editbutton: UIButton! {
        didSet {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                editbutton.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            let image = editbutton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            editbutton.setImage(image, for: .normal)
            editbutton.imageView?.tintColor = ApplicationTheme.currentTheme.buttonthemeBasePrimaryBlackColor
            
        }
    }
    @IBOutlet var btnConfirm: UIButton! {
        didSet {
//            btnConfirm.setTitle(localizedString("lbl_confirm", comment: ""), for: .normal)
        }
    }
    @IBOutlet var ViewNoProduct: AWView!
    @IBOutlet var editViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewAllBGView: UIView! {
        didSet {
            viewAllBGView.backgroundColor = ApplicationTheme.currentTheme.buttonthemeBasePrimaryBlackColor
            viewAllBGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 15)
        }
    }
    @IBOutlet var lblViewAll: UILabel! {
        didSet {
            lblViewAll.setBody3BoldUpperButtonLabelStyle(true)
            lblViewAll.textColor = ApplicationTheme.currentTheme.buttonthemeBaseBlackPrimaryForeGroundColor
        }
    }
    @IBOutlet var imgViewAllArrow: UIImageView! {
        didSet {
            
            imgViewAllArrow.image = UIImage(name: "arrowForwardSmiles")
            
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.imgViewAllArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
        }
    }
    @IBOutlet var btnCancel: UIButton! {
        didSet {
            btnCancel.setTitle(localizedString("promo_code_alert_no", comment: ""), for: UIControl.State())
        }
    }
    
    /* {
        
        didSet {
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                ViewNoProduct.transform = CGAffineTransform(scaleX: -1, y: 1)
                ViewNoProduct.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
        }
        
    }*/
    
    private var bannerWorkItem:DispatchWorkItem?
    
    @IBOutlet weak var bannerCollectionViewFrameHeight: NSLayoutConstraint! {
        didSet{
            
            if self.customCollectionViewWithBanner != nil {
                self.customCollectionViewWithBanner.layoutIfNeeded()
                self.customCollectionViewWithBanner.setNeedsLayout()
            }
           
        }
    }
    
    var grocery:Grocery? {
        didSet{
            customCollectionViewWithBanner.grocery = self.grocery
        }
    }

    var homeFeed:Home? {
        
        didSet{
            customCollectionViewWithBanner.homeFeed = self.homeFeed
            customCollectionViewWithBanner.reloadData()
            if self.homeFeed != nil {
               /* if (self.homeFeed?.banners.count ?? 0 > 0){
                    for banner in homeFeed?.banners ?? [] {
                        let bannerID = banner.bannerId.stringValue
                        let topVCName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
                        if !UserDefaults.isBannerDisplayed(bannerID , topControllerName: topVCName ) {
                            elDebugPrint("banner.bannerId : \(banner.bannerId.stringValue)")
                            let isSingle =   banner.bannerGroup.int32Value != KRecipeBannerID
                            for bannerLink in banner.bannerLinks {
                                FireBaseEventsLogger.trackBannerView(isSingle: isSingle , brandName: ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "" , bannerLink.bannerCategory?.nameEn ?? bannerLink.bannerCategory?.name ?? ""  , bannerLink.bannerSubCategory?.subCategoryNameEn ?? bannerLink.bannerSubCategory?.subCategoryName ?? "", link: bannerLink )
                                UserDefaults.addBannerID(bannerID, topControllerName: topVCName)
                            }
                        }
                    }
                }*/
            }
        }
        
    }
    var changeSearchResult: ((String? , Int?)->Void)?
    var goToSearchVCWith: ((String? , Int? )->Void)?
    var currentIndex : Int?
    var isNeedToCallService : Bool = true
    var currentSearchString : String? = "" {
         didSet {
            self.newSearchTextField.text = currentSearchString
        }
    }
    
    @IBOutlet  var newSearchTextField: UITextField!
    @IBOutlet weak var searchItemLable: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.viewMoreButton.setTitle(localizedString("view_more_title", comment: ""), for: .normal)
//        self.viewMoreButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(12)
        self.lblViewAll.text = localizedString("view_more_title", comment: "")
        self.lblNoProductFound.text = localizedString("No_Product_Found_Msg", comment: "")
        self.customCollectionView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.lblNoProductFound.textAlignment = .right
            self.newSearchTextField.textAlignment = .right
        }
        self.addClousure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func addClousure() {
                
        guard self.customCollectionView != nil else {
            return
        }
    self.customCollectionView.productCellOnFavouriteClick = { [weak self] (productCell,product) in
        guard let self = self  else {
            return
        }
        if self.delegate != nil {
            self.delegate?.productCellOnFavouriteClick(productCell, product: product)
        }
    }
    self.customCollectionView.productCellOnProductQuickAddButtonClick = { [weak self] (productCell,product) in
        guard let self = self  else {
            return
        }
        if self.delegate != nil {
            self.delegate?.productCellOnProductQuickAddButtonClick(productCell, product: product)
        }
        self.customCollectionView.reloadData()
    }
    self.customCollectionView.productCellOnProductQuickRemoveButtonClick = { [weak self] (productCell,product) in
        guard let self = self  else {
            return
        }
        if self.delegate != nil {
            self.delegate?.productCellOnProductQuickRemoveButtonClick(productCell, product: product)
        }
        self.customCollectionView.reloadData()

    }
    self.customCollectionView.chooseReplacementWithProduct = { [weak self] (product) in
        guard let self = self  else {
            return
        }
        if self.delegate != nil {
            self.delegate?.chooseReplacementWithProduct(product)
        }
    }
    self.customCollectionView.viewMoreCalled = { [weak self] () in
        guard let self = self  else {
            return
        }
        self.viewMoreHandler(self.viewMoreButton as Any)
    }

}
    @IBAction func btnCancelHandler(_ sender: Any) {
        
        self.searchItemLable.text = currentSearchString
        self.editActionHandler(self.editView as Any)
    }
    @IBAction func editActionHandler(_ sender: Any) {
        UIView.transition(with: self.editView, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let self = self else {return}
           self.editView.isHidden = !self.editView.isHidden
            self.editView.layer.borderColor = ApplicationTheme.currentTheme.buttonTextWithClearBGColor.cgColor
        })
        self.newSearchTextField.placeholder = currentSearchString
        self.newSearchTextField.text = currentSearchString
        if !self.editView.isHidden {
            self.newSearchTextField.becomeFirstResponder()
            self.btnCancel.isHidden = false
            self.viewAllBGView.isHidden = true
            self.editViewTrailingConstraint.constant = -5
        }else{
            self.newSearchTextField.resignFirstResponder()
            self.btnCancel.isHidden = true
            self.viewAllBGView.isHidden = false
            self.editViewTrailingConstraint.constant = 12
        }
    }
    @IBAction func searchActionHandler(_ sender: Any) {
        if self.changeSearchResult != nil {
            FireBaseEventsLogger.trackMultiSearchEditClick([ FireBaseParmName.SearchTerm.rawValue + "Old"  : currentSearchString ?? "" , FireBaseParmName.SearchTerm.rawValue + "New"  : newSearchTextField.text ?? ""])
            self.changeSearchResult!(newSearchTextField.text ?? nil , self.currentIndex ?? nil )
            self.editActionHandler(self.editView as Any)
            newSearchTextField.text = ""
        }
    }
    @IBAction func viewMoreHandler(_ sender: Any) {

        if self.goToSearchVCWith != nil {
            FireBaseEventsLogger.trackViewMoreClick(["Name" : currentSearchString ?? ""])
            self.goToSearchVCWith!(currentSearchString,  self.currentIndex ?? nil)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        if(textField.returnKeyType == .search){
            self.searchActionHandler(editView as Any)
        }
        return true
    }

    //MARK:- Banner calling  Methods -
    // MARK: Banners Products

    func removeBannerCall () {
        if let bannerWork = self.bannerWorkItem {
            bannerWork.cancel()
        }
    }

    func getBanners(searchInput : String ){

        guard !searchInput.isEmpty else {
            return
        }
        //self.removeBannerCall()
        self.bannerWorkItem = DispatchWorkItem {
            if let gorceryId = self.grocery?.dbID {
                self.getBannersFromServer(gorceryId , searchInput: searchInput)
            }
        }
        DispatchQueue.global(qos: .userInitiated).async(execute:  self.bannerWorkItem!) }

    private func getBannersFromServer(_ gorceryId:String , searchInput : String){

        let homeTitle = "Banners"

        let parameters = NSMutableDictionary()
        parameters["limit"] = 1
        parameters["offset"] = 0
        parameters["retailer_id"] = gorceryId
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        parameters["search_input"] = searchInput
        parameters["banner_type"] = SearchBannerType.Serach.getString()

        ElGrocerApi.sharedInstance.getBannersOfGrocery(parameters) { (result) in

            switch result {

            case .success(let response):
                self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId)

            case .failure(let error):
                elDebugPrint(error.localizedMessage)
               // error.showErrorAlert()
            }
        }
    }

    func saveBannersResponseData(_ responseObject:NSDictionary, withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String) {

        if (self.grocery?.dbID == gorceryId) {

            //self.isProcessingBanners = true
            let banners = Banner.getBannersFromResponse(responseObject)
            // elDebugPrint("Banners Array Count:%d",banners.count)

           // ElGrocerUtility.sharedInstance.bannerGroups = banners.group(by: {$0.bannerGroup})

            let keys = ElGrocerUtility.sharedInstance.bannerGroups.keys
            // elDebugPrint("Banner Keys:%@",keys)
            let groupKeys = keys // .sorted(by: <)

            for key in groupKeys {

               let bannerArray = ElGrocerUtility.sharedInstance.bannerGroups[key]
                self.homeFeed = Home.init(homeTitle, withCategory: nil, withBanners: bannerArray, withType:HomeType.Banner,  products: [])
            }
            
            if self.delegate != nil  {
                
                self.delegate?.addBannerFor(currentIndex ?? -1 , searchResultString : currentSearchString ?? "" , homeFeed: self.homeFeed)
                //self.delegate?.reloadCellIndexForBanner(currentIndex ?? -1, cell: self)
                
            }
            
        }

    }
    

}
