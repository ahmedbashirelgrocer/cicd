//
//  GenericHyperMrketHeader.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 14/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

enum GenericHyperMarketHeaderType {
    case hyperMarket
    case specialityStore
    case none
}

class GenericHyperMarketHeader: UIView {

    @IBOutlet var cellBGView: UIView!{
        didSet{
            cellBGView.backgroundColor = ApplicationTheme.currentTheme.navigationBarColor
        }
    }
    @IBOutlet var bestForView: UIView!{
        didSet{
            bestForView.backgroundColor = .replacementGreenBGColor()
            bestForView.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8, withShadow: false)
            
        }
    }
    @IBOutlet weak var bestForViewTopConstraints: NSLayoutConstraint!
    @IBOutlet var bestForViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var bestForViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var lblBestFor: UILabel!{
        didSet{
            lblBestFor.setCaptionOneBoldUperCaseDarkGreenStyle()
            lblBestFor.text = localizedString("lbl_Best_For", comment: "")
        }
    }
    @IBOutlet var lblScheduledDelivery: UILabel!{
        didSet{
            lblScheduledDelivery.setBody3RegDarkGreenStyle()
            lblScheduledDelivery.numberOfLines = 1
        }
    }
    @IBOutlet var lblGreatPrices: UILabel!{
        didSet{
            lblGreatPrices.setBody3RegDarkGreenStyle()
            lblGreatPrices.numberOfLines = 1
        }
    }
    @IBOutlet var searchBarSuperBGView: UIView!{
        didSet{
            searchBarSuperBGView.backgroundColor = .textfieldBackgroundColor()
            searchBarSuperBGView.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner], radius: 24, withShadow: false)
        }
    }
    @IBOutlet var searchBGView: UIView!{
        didSet{
            searchBGView.backgroundColor = .navigationBarWhiteColor()
            searchBGView.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 22, withShadow: false)
            searchBGView.layer.borderWidth = 1
            searchBGView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        }
    }
    @IBOutlet var txtSearchBar: UITextField!{
        didSet{
            txtSearchBar.placeholder = localizedString("search_placeholder_hypermarket", comment: "")
            txtSearchBar.setPlaceHolder(text: localizedString("search_placeholder_hypermarket", comment: ""))
            txtSearchBar.setBody1RegStyle()
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                txtSearchBar.textAlignment = .right
            }else{
                txtSearchBar.textAlignment = .left
            }
        }
    }
    @IBOutlet var imgSearch: UIImageView!{
        didSet{
            imgSearch.image = UIImage(name: "search-SearchBar")
        }
    }
    
    var headerType: GenericHyperMarketHeaderType = .hyperMarket
    let headerMinimumHeight: CGFloat = 76
    let headerMaximumHeight: CGFloat = 189
    var retailerType: RetailerType? = nil
    var searchBarTapped: (()->Void)?
    
    class func loadFromNib() -> GenericHyperMarketHeader? {
        return self.loadFromNib(withName: "GenericHyperMarketHeader")
    }
    
    override func awakeFromNib() {
        setInitialUI(type: headerType)

        super.awakeFromNib()
        setSearchDelegate()
    }

    func setInitialUI(type: GenericHyperMarketHeaderType){
        if type == .hyperMarket{
            self.bestForViewTopConstraints.constant = 16
            self.bestForViewBottomConstraint.constant = 24
            self.bestForView.visibility = .visible
        }else{
            self.bestForViewTopConstraints.constant = 0
            self.bestForViewBottomConstraint.constant = 0
            self.bestForViewHeightConstraint.constant = 0
            self.bestForView.visibility = .gone
        }
        
    }
    
    func setSearchDelegate(){
        self.txtSearchBar.delegate = self
    }
    
    func setTextFor (firstDesc : String, secondDesc: String) {
        self.lblScheduledDelivery.text = firstDesc
        self.lblGreatPrices.text = secondDesc
        
    }
    
    func navigationBarSearchTapped() {
       elDebugPrint("Implement in controller")
        guard let vc = UIApplication.topViewController() else {return}
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        searchController.navigationFromControllerName = FireBaseScreenName.GenericHome.rawValue
        searchController.searchFor = .isForUniversalSearch
        searchController.presentingVC = vc
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [searchController]
        
        navigationController.modalPresentationStyle = .fullScreen
            // self.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = false
        
        vc.present(navigationController, animated: true, completion: nil)
        
        ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "1" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
        if let id = self.retailerType?.dbId, let name = self.retailerType?.getRetailerName() {
            MixpanelEventLogger.trackStoreListingSearch(storeListCategoryId: "\(id)", storeListCategoryName: name)
        }
        ElGrocerUtility.sharedInstance.delay(1.0) {
            if searchController.txtSearch != nil {
                searchController.txtSearch.becomeFirstResponder()
            }
        }
        
        
    }
}
extension GenericHyperMarketHeader: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtSearchBar{
            if let clouser = self.searchBarTapped {
                clouser()
            } else {
                navigationBarSearchTapped()
            }
        }
    }
}
