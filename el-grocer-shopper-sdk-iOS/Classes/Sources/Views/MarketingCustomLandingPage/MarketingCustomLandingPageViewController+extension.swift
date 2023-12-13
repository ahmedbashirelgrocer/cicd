//
//  MarketingCustomLandingPageViewController+extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 27/11/2023.
//

import Foundation

extension MarketingCustomLandingPageViewController: NavigationBarProtocol {
    
    
    func addLocationHeader() {
        
        guard self.viewModel.getGrocery() != nil else { return }
        
        
        // For shoppor
        if sdkManager.launchOptions?.marketType == .shopper {
            addLocationHeaderShopper(); return  }
        self.view.addSubview(self.locationHeaderFlavor)
        self.setLocationViewFlavorHeaderConstraints()

        self.view.addSubview(self.locationHeader)
        self.setLocationViewConstraints()
        
    }
    
     func setLocationViewConstraints() {
        
        self.locationHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeader.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0)
          
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeader.headerMaxHeight)
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
      
    }
    
     func setLocationViewFlavorHeaderConstraints() {
        
        self.locationHeaderFlavor.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeaderFlavor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeaderFlavor.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeaderFlavor.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0)
          
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeaderFlavor, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeaderFlavor, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeaderFlavor.headerMaxHeight)
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
      
    }
    
    func addLocationHeaderShopper() {
        
        self.view.addSubview(self.locationHeaderShopper)
        
        NSLayoutConstraint.activate([
            locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            locationHeaderShopper.leftAnchor.constraint(equalTo: view.leftAnchor),
            locationHeaderShopper.rightAnchor.constraint(equalTo: view.rightAnchor),
            locationHeaderShopper.bottomAnchor.constraint(equalTo: tableView.topAnchor)
        ])
        
    }
    
     func adjustHeaderDisplay() {
        
        // print("sdkManager.isGrocerySingleStore: \(sdkManager.isGrocerySingleStore)")

        self.locationHeaderFlavor.isHidden = !sdkManager.isGrocerySingleStore
        self.locationHeader.isHidden = sdkManager.isGrocerySingleStore
        
        let constraintA = self.locationHeaderFlavor.constraints.filter({$0.firstAttribute == .height})
        if constraintA.count > 0 {
            let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
            let headerViewHeightConstraint = constraint
            headerViewHeightConstraint.isActive  = sdkManager.isGrocerySingleStore
        }else {
            
            if sdkManager.isGrocerySingleStore {
                let heightConstraint = NSLayoutConstraint(item: self.locationHeaderFlavor, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeaderFlavor.headerMaxHeight)
                NSLayoutConstraint.activate([heightConstraint])
            }
           
        }
        
        let locationHeaderConstraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
        if locationHeaderConstraintA.count > 0 {
            let constraint = locationHeaderConstraintA.count > 1 ? locationHeaderConstraintA[1] : locationHeaderConstraintA[0]
            let headerViewHeightConstraint = constraint
            headerViewHeightConstraint.isActive  = !sdkManager.isGrocerySingleStore
        } else {
            if !sdkManager.isGrocerySingleStore {
                let heightConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeader.headerMaxHeight)
                NSLayoutConstraint.activate([heightConstraint])
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func setHeaderData(_ grocery : Grocery?) {
        guard let grocery = grocery  else{
            return
        }
        addBasketIcon(grocery)
        
        if sdkManager.launchOptions?.marketType == .shopper {
            DispatchQueue.main.async {
                self.locationHeaderShopper.configuredLocationAndGrocey(grocery)
            }
            return
        }
        
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            sdkManager.isGrocerySingleStore ?
            self.locationHeaderFlavor.configureHeader(grocery: grocery, location: ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress(), isArrowDownHidden: false): self.locationHeader.configureCell(grocery)
        })
        
    }
    
    func setupNavigationBar() {
        if !sdkManager.isGrocerySingleStore {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            //(self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
        }
        self.navigationItem.hidesBackButton = true
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setNavBarHidden(sdkManager.isGrocerySingleStore)
            controller.setupGradient()
        }

        if sdkManager.isShopperApp {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    func addBasketIcon(_ grocery : Grocery?) {
        if grocery != nil {
            addBasketIconOverlay(self, grocery: grocery, shouldShowGroceryActiveBasket:  grocery != nil)
            self.basketIconOverlay?.grocery = grocery
            self.basketIconOverlay?.shouldShow = true
            self.refreshBasketIconStatus()
        }
    }
    
    
    @objc func backButtonPressed() {
        backButtonClickedHandler()
    }
    
    
    func backButtonClickedHandler() {
        self.dismiss(animated: true)
    }
     
}

extension MarketingCustomLandingPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let grocery =  self.viewModel.getGrocery() else {return}
        // For shopper
        if AppSetting.currentSetting.isElgrocerApp() {
            self.scrollViewDidScrollForShopper(forShopper: scrollView)
            return
        }
        scrollView.layoutIfNeeded()
        guard !sdkManager.isGrocerySingleStore else {
            let constraintA = self.locationHeaderFlavor.constraints.filter({$0.firstAttribute == .height})
            if constraintA.count > 0 {
                let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
                let headerViewHeightConstraint = constraint
                let maxHeight = self.locationHeaderFlavor.headerMaxHeight
                headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,self.locationHeaderFlavor.headerMinHeight),maxHeight)
            }
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
            return
        }
        
        let constraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
        if constraintA.count > 0 {
            let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
            let headerViewHeightConstraint = constraint
            let maxHeight = self.locationHeader.headerMaxHeight
            headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,64),maxHeight)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.locationHeader.myGroceryName.alpha = scrollView.contentOffset.y < 10 ? 1 : scrollView.contentOffset.y / 100
        }
       
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.locationHeader.myGroceryImage.alpha = scrollView.contentOffset.y > 40 ? 0 : 1
            let title = scrollView.contentOffset.y > 40 ? grocery.name : ""
            self.navigationController?.navigationBar.topItem?.title = title
            sdkManager.isSmileSDK ?  (self.navigationController as? ElGrocerNavigationController)?.setSecondaryBlackTitleColor() :  (self.navigationController as? ElGrocerNavigationController)?.setWhiteTitleColor()
           
            self.title = title
        }
   
    }
    
    
    func shopperLocationHeaderReset() {
        offset = 0
        let value = min(effectiveOffset, 0)
        self.locationHeaderShopper.searchViewTopAnchor.constant = 62 - value
        self.locationHeaderShopper.searchViewLeftAnchor.constant = 16 + ((value / 60) * 30)
        self.locationHeaderShopper.groceryBGView.alpha = max(0, 1 - (value / 60))
    }
    
    func scrollViewDidScrollForShopper(forShopper scrollView: UIScrollView) {
        offset = scrollView.contentOffset.y - paddingOffset
        let value = min(effectiveOffset, scrollView.contentOffset.y - paddingOffset)
        
        self.locationHeaderShopper.searchViewTopAnchor.constant = 62 - value
        self.locationHeaderShopper.searchViewLeftAnchor.constant = 16 + ((value / 60) * 30)
        self.locationHeaderShopper.groceryBGView.alpha = max(0, 1 - (value / 60))
    }
    
  
}
