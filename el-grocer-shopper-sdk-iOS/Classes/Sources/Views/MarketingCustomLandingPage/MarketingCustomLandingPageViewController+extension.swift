//
//  MarketingCustomLandingPageViewController+extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 27/11/2023.
//

import Foundation

extension MarketingCustomLandingPageViewController: NavigationBarProtocol {
    
    
    func addLocationHeader() {
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
    
    func backButtonClickedHandler() {
        self.dismiss(animated: true)
    }
    
    
    
    
}
