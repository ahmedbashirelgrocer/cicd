//
//  SearchListViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 30/08/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
class SearchListViewController: UIViewController , NoStoreViewDelegate ,UIScrollViewDelegate, NavigationBarProtocol {
    
    

    @IBOutlet var btnCross: UIButton!
    var grocery : Grocery?

    @IBOutlet var viewCreateSHppingListProcess: AWView!
    @IBOutlet var checkMarkCreateSHppingListProcess: UIImageView!
    @IBOutlet var txtCreateShoppingList: UILabel! {
        didSet{
            txtCreateShoppingList.text = NSLocalizedString("lbl_shopping_list", comment: "Create your shopping list")
        }
    }
    
    
    
    @IBOutlet var viewSearchAndShopProductsProcess: AWView!
    @IBOutlet var checkSearchAndShopProductsProcess: UIImageView!
    @IBOutlet var txtSearchAndShopProducts: UILabel!{
        didSet{
            txtSearchAndShopProducts.text = NSLocalizedString("lbl_search_shop", comment: "Search and shop products")
        }
    }
    
    
    @IBOutlet var lblOne: UILabel! {
        didSet {
            lblOne.text = NSLocalizedString("lbl_One", comment: "")
        }
    }
    @IBOutlet var lblTwo: UILabel!{
        didSet {
            lblTwo.text = NSLocalizedString("lbl_Two", comment: "")
        }
    }
    
    @IBOutlet var scrollviewContentView: UIView!{
        didSet{
            scrollviewContentView.backgroundColor = .navigationBarColor()
        }
    }
    @IBOutlet var searchListBGSuperView: UIView!{
        didSet{
            searchListBGSuperView.roundWithShadow(corners: [.layerMinXMinYCorner , .layerMaxXMinYCorner], radius: 24, withShadow: false)
        }
    }
    
    
    @IBOutlet var LocationHeaderBGHeight: NSLayoutConstraint!{
        didSet{
            LocationHeaderBGHeight.constant = 0
        }
    }
    @IBOutlet var locationHGeaderBG: UIView!{
        didSet{
            locationHGeaderBG.backgroundColor = .navigationBarColor()
        }
    }
//    lazy var locationHeader : ElgrocerlocationView = {
//        let locationHeader = ElgrocerlocationView.loadFromNib()
//        return locationHeader!
//    }()
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoDefaultSelectedStoreForShopingList()
        return noStoreView!
    }()
    func noDataButtonDelegateClick(_ state: actionState) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBOutlet var searchProductListingTextView: UITextView!{
        didSet{
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    searchProductListingTextView.textAlignment = .right
                }else{
                    searchProductListingTextView.textAlignment = .left
                }
                
            }
            
        }
    }
    @IBOutlet var searchButton: AWButton!
    
    
    var isFromHeader: Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.setUpApearence()
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        if self.grocery != nil{
            if isFromHeader{
                self.addRightCrossButton(true)
            }
        }else{
//            (self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
        }
        
//        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        
       // self.searchProductListingTextView.inputView = self.searchButton
        
        FireBaseEventsLogger.setScreenName( FireBaseScreenName.ShoppingList.rawValue , screenClass: String(describing: self.classForCoder))
        
       
    }
    
    override func rightBackButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 25){
            self.view.endEditing(true)
            //debugPrint(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y)
        } else {
            debugPrint(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
            self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        }
        if self.grocery == nil  {
            self.NoDataView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.addSubview(NoDataView)
        }else{
             self.setUpApearence()
        }
        self.NoDataView.isHidden = !(self.grocery == nil)
    }
    
    @IBAction func crossAction(_ sender: Any) {
        self.searchProductListingTextView.textColor = .navigationBarColor()
        self.searchProductListingTextView.text =   NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "")
        self.btnCross.isHidden = true
        self.searchProductListingTextView.resignFirstResponder()
    }
    func setUpApearence() {
        
        self.title = NSLocalizedString("Add_Shopping_list_Title", comment: "")
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = NSLocalizedString("lbl_ShopSearch", comment: "")
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
       // [textField.keyboardToolbar.doneBarButton setTarget:self action:@selector(doneAction:)];
        self.searchProductListingTextView.keyboardToolbar.doneBarButton.tintColor = .navigationBarColor()
        self.searchProductListingTextView.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(SearchListViewController.searchAction))
        
        
        self.searchProductListingTextView.delegate = self
        self.searchProductListingTextView.textColor = UIColor.navigationBarColor()
        self.searchProductListingTextView.text = NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "")
        self.searchButton.setTitle(NSLocalizedString("lbl_ShopSearch", comment: ""), for: .normal)
        self.setUIColor(self.searchProductListingTextView)
        
//        locationHeader.configuredLocationAndGrocey(ElGrocerUtility.sharedInstance.activeGrocery)
//        locationHGeaderBG.addSubview(locationHeader)
//        LocationHeaderBGHeight.constant = locationHeader.frame.size.height
//        locationHeader.frame = locationHGeaderBG.frame
        
        
        self.makeShopingListModuleEnable(true)
        self.makeSearchAndShopModuleEnable(false)
        
        if  let lastSearchString = UserDefaults.getLastSearchList() {
            if !lastSearchString.isEmpty &&   lastSearchString != NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "") {
                self.searchProductListingTextView.text = lastSearchString
                self.searchProductListingTextView.textColor = .newBlackColor()
                self.setUIColor(self.searchProductListingTextView)
            }
        }

        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        
    }
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = nil
    }
    
    func makeShopingListModuleEnable (_ isEnable : Bool) {
        
        checkMarkCreateSHppingListProcess.isHidden = !isEnable
        
        if isEnable {
            viewCreateSHppingListProcess.backgroundColor = UIColor.navigationBarColor()
            txtCreateShoppingList.textColor = UIColor.navigationBarColor()
        }else{
            viewCreateSHppingListProcess.backgroundColor = UIColor(red: 0.347, green: 0.347, blue: 0.347, alpha: 0.16)
            txtCreateShoppingList.textColor = UIColor(red: 0.567, green: 0.567, blue: 0.567, alpha: 1)
        }
   
    }
    
    func makeSearchAndShopModuleEnable (_ isEnable : Bool) {
        
        
        checkSearchAndShopProductsProcess.isHidden = !isEnable
        
        if isEnable {
            viewSearchAndShopProductsProcess.backgroundColor = UIColor.navigationBarColor()
            txtSearchAndShopProducts.textColor = UIColor.navigationBarColor()
        }else{
            viewSearchAndShopProductsProcess.backgroundColor = UIColor(red: 0.347, green: 0.347, blue: 0.347, alpha: 0.16)
            txtSearchAndShopProducts.textColor = UIColor(red: 0.567, green: 0.567, blue: 0.567, alpha: 1)
        }

    }
    
  
    
    
    
    @objc
    func searchAction() {
        searchButtonHandler("")
    }
    
    

    @IBAction func searchButtonHandler(_ sender: Any) {
        
        if self.searchProductListingTextView.text == NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "") {
            self.view.endEditing(true)
            return
        }
        
        if self.searchProductListingTextView.text.count == 0 {
            self.view.endEditing(true)
            return
        }
        
        guard !self.searchProductListingTextView.text.trimmingCharacters(in: .whitespaces).isEmpty && self.searchProductListingTextView.text.count > 0 && self.searchProductListingTextView.text != NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "")  else {
            self.searchProductListingTextView.resignFirstResponder()
            return
        }
        
        FireBaseEventsLogger.trackMultiSearch(self.searchProductListingTextView.text ?? "")
        UserDefaults.setLastSearchList(self.searchProductListingTextView.text)
        GoogleAnalyticsHelper.trackMultiSearchShopClick()
        
        
        let shoppingListVc = ElGrocerViewControllers.shoppingListViewController()
        shoppingListVc.searchList = self.searchProductListingTextView.text.lowercased()
        shoppingListVc.grocery = self.grocery
        if isFromHeader{
            shoppingListVc.isFromHeader = true
        }
        self.navigationController?.pushViewController(shoppingListVc, animated: true)
        
    }
    

}
extension SearchListViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.tintColor = UIColor.darkTextGrayColor()
        
        if textView.text == NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "") {
            textView.text = nil
            textView.textColor = UIColor.newBlackColor()//colorWithHexString(hexString: "787878")
            self.setUIColor(textView)
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.setUIColor(textView)
        
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "")
            textView.textColor = UIColor.navigationBarColor()//lightTextGrayColor()
        }
       
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        defer {
            UserDefaults.setLastSearchList(self.searchProductListingTextView.text)
        }
       
        if textView.text == NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "") {
            textView.text = nil
            textView.textColor = UIColor.newBlackColor()//colorWithHexString(hexString: "787878")
            self.btnCross.isHidden = true
        }
        if textView.text.count > 0 {
            self.btnCross.isHidden =  false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
         self.setUIColor(textView)
    
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange  range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
           textView.resignFirstResponder()
            performAction()
        }
        return true
    }
    
    func performAction() {
        self.searchButtonHandler("")
    }
    
    func setUIColor (_ textView : UITextView) {
        
        self.searchButton.layer.cornerRadius = 29
        
        
        if !textView.text.trimmingCharacters(in: .whitespaces).isEmpty && textView.text.count > 0 &&  (textView.text != NSLocalizedString("shopping_PlaceHolder_Search_List", comment: "")){
            // self.searchButton.setImage(UIImage(named: "icSearchGreen"), for: .normal)
            textView.textColor = .newBlackColor()//UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            self.searchButton.setTitle(NSLocalizedString("lbl_ShopSearch", comment: ""), for: .normal)
            self.searchButton.setBackgroundColor(UIColor.navigationBarColor(), forState: .normal)
            //   self.searchButton.setTitleColor(UIColor.lightGrayBGColor(), for: .normal)
            
            self.makeShopingListModuleEnable(true)
            self.makeSearchAndShopModuleEnable(false) // self.makeSearchAndShopModuleEnable(true)
            
            
        }else{
            // self.searchButton.setImage(UIImage(named: "icSearch"), for: .normal)
            textView.textColor = .navigationBarColor()//UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.74)
            self.searchButton.setTitle(NSLocalizedString("lbl_ShopSearch", comment: ""), for: .normal)
            self.searchButton.setBackgroundColor(UIColor(red: 0.567, green: 0.567, blue: 0.567, alpha: 1) , forState: .normal)
            
            self.makeShopingListModuleEnable(true)
            self.makeSearchAndShopModuleEnable(false)
            //  self.searchButton.setTitleColor(UIColor.lightGrayBGColor(), for: .normal)
        }
        
    }
    
}
