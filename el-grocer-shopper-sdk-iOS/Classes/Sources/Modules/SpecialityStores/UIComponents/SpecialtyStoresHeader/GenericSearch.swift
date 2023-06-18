//
//  GenericHyperMrketHeader.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 14/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class GenericSearch: UIView {

    @IBOutlet var cellBGView: UIView!
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
            txtSearchBar.placeholder = NSLocalizedString("search_placeholder_hypermarket", comment: "")
            txtSearchBar.setPlaceHolder(text: NSLocalizedString("search_placeholder_hypermarket", comment: ""))
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
    
    var searchBarTapped: (()->Void)?
    
    class func loadFromNib() -> GenericSearch? {
        return self.loadFromNib(withName: "GenericSearch")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setSearchDelegate()
    }
    
    func setSearchDelegate(){
        self.txtSearchBar.delegate = self
    }
    
    func navigationBarSearchTapped() {
        print("Implement in controller")
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
//        if let id = self.retailerType?.dbId, let name = self.retailerType?.getRetailerName() {
//            MixpanelEventLogger.trackStoreListingSearch(storeListCategoryId: "\(id)", storeListCategoryName: name)
//        }
        ElGrocerUtility.sharedInstance.delay(1.0) {
            if searchController.txtSearch != nil {
                searchController.txtSearch.becomeFirstResponder()
            }
        }
        
        
    }
}
extension GenericSearch: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtSearchBar{
            if let clouser = self.searchBarTapped {
                clouser()
            } else {
                navigationBarSearchTapped()
            }
        }
        return false
    }
}
