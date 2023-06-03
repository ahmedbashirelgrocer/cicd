//
//  DashboardLocationCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kDashboardLocationCellIdentifier = "DashboardLocationCell"
let kDashboardLocationCellHeight:CGFloat = 60.0

protocol DashboardLocationCellProtocol : class {
    
    func dashboardLocationCellDidTouchEditButton(_ cell:DashboardLocationCell) -> Void
    func dashboardLocationCellDidTouchDeleteButton(_ cell:DashboardLocationCell) -> Void
}

class DashboardLocationCell : UITableViewCell {
    
    @IBOutlet weak var borderContainer: UIView!
   // @IBOutlet weak var mainContainer: UIView!
    @IBOutlet var userName: UILabel!
    @IBOutlet weak var locationName: UILabel!
//    @IBOutlet weak var locationAddress: UILabel!
//    @IBOutlet weak var activeLocationIcon: UIImageView!
//    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var defaultButton: UIButton! {
        didSet {
            defaultButton.setTitle(localizedString("btn_default", comment: ""), for: UIControl.State())
            defaultButton.setTitleColor(ApplicationTheme.currentTheme.buttonTextWithClearBGColor, for: UIControl.State())
        }
    }
    
    weak var delegate:DashboardLocationCellProtocol?
    
    let kMaxCellTranslation: CGFloat = 80
    var currentTranslation:CGFloat = 0
    
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
      //  setUpContainerAppearance()
        setUpLocationNameAppearance()
        setUpLocationAddressAppearance()
        setUpActionButtonsAppearance()
        
        addPanGesture()
        self.backgroundColor = .textfieldBackgroundColor()
        self.contentView.backgroundColor = .textfieldBackgroundColor()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.currentTranslation = 0
       // self.mainContainer.transform = CGAffineTransform.identity
    }
    
    // MARK: Appearance
    
    fileprivate func setUpContainerAppearance() {
        
        self.borderContainer.layer.cornerRadius = 12
        self.borderContainer.layer.borderWidth = 1
        self.borderContainer.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        self.borderContainer.layer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
    }
    
    fileprivate func setUpLocationNameAppearance() {
        
//        self.locationName.textColor = UIColor.black
//        self.locationName.font = UIFont.mediumFont(13.0)
    }
    
    fileprivate func setUpLocationAddressAppearance() {
        
    //    self.locationAddress.textColor = UIColor.lightTextGrayColor()
      //  self.locationAddress.font = UIFont.bookFont(11.0)
    }
    
    fileprivate func setUpActionButtonsAppearance() {
        
        self.editButton.setTitleColor(UIColor.selectionTabDark(), for: UIControl.State())
        self.editButton.setTitle("  " + localizedString("dashboard_location_edit_button", comment: ""), for: UIControl.State())
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            if let btnImage = self.editButton.currentImage {
                self.editButton.setImage(btnImage.withHorizontallyFlippedOrientation(), for: UIControl.State())
            }
        }
        
//        self.deleteButton.backgroundColor = UIColor.redValidationErrorColor()
        self.deleteButton.setTitleColor(UIColor.selectionTabDark(), for: UIControl.State())
//        self.deleteButton.titleLabel?.font = UIFont.mediumFont(11.0)
        self.deleteButton.setTitle("  " + localizedString("dashboard_location_delete_button", comment: ""), for: UIControl.State())
    }
    
    // MARK: Data
    
    func configureWithLocation(_ location:DeliveryAddress , _ isFromCart : Bool = false) {
        
        self.userName.text = location.nickName ?? location.shopperName ?? ""
        
        let adr = ElGrocerUtility.sharedInstance.getFormattedAddress(location)
        var address = location.address
        address = ""
        if adr.count > 0 && location.phoneNumber?.count ?? 0 > 0 {
            self.locationName.text =  (location.phoneNumber ?? "") + "\n" + ElGrocerUtility.sharedInstance.getFormattedAddress(location) + (address.count > 0 ? ( "\n" + address) : "")
        }else if location.phoneNumber?.count ?? 0 == 0 {
           self.locationName.text =  ElGrocerUtility.sharedInstance.getFormattedAddress(location)
        }
       
//        self.locationAddress.text = location.locationName
//        self.activeLocationIcon.isHidden = !location.isActive.boolValue
        self.editButton.isHidden = !UserDefaults.isUserLoggedIn()
    //    self.homeIcon.image = location.isActive.boolValue ? UIImage(name: "home-icon-selected") :  UIImage(name: "home-icon")
        self.deleteButton.isHidden = location.isActive.boolValue
        self.defaultButton.isHidden = !location.isActive.boolValue
        
        if !isFromCart {
            if location.isActive.boolValue == true {
                borderContainer.layer.borderColor = ApplicationTheme.currentTheme.primarySelectionColor.cgColor
                borderContainer.layer.borderWidth = 2
                borderContainer.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
            }else{
                borderContainer.layer.borderColor = ApplicationTheme.currentTheme.textFieldBorderInActiveClearColor.cgColor
                borderContainer.layer.borderWidth = 0
                borderContainer.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
            }
        }
        
        
        
    }
    
    
    
    
   
    
    
    
    // MARK: PanGesture
    
    func addPanGesture() {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DashboardLocationCell.handlePanGesture(_:)))
        panGesture.cancelsTouchesInView = true
        panGesture.delegate = self
        
        self.addGestureRecognizer(panGesture)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
            
        case .changed:

            let translation = recognizer.translation(in: self.borderContainer)
            var xOffset: CGFloat = self.currentTranslation + translation.x
            
            if xOffset > kMaxCellTranslation {
                
                xOffset = kMaxCellTranslation
                
            } else if xOffset < -kMaxCellTranslation {
                xOffset = -kMaxCellTranslation
            }
            
          //  self.mainContainer.transform = CGAffineTransform(translationX: xOffset, y: 0)
            
        case .ended:
            
            let translation = recognizer.translation(in: self.borderContainer)
            var xOffset: CGFloat = self.currentTranslation + translation.x
            
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            
            if xOffset >= kMaxCellTranslation / 2 {
                
                if UserDefaults.isUserLoggedIn(){
                    xOffset = kMaxCellTranslation
                }else{
                    if currentLang == "ar" {
                        xOffset = kMaxCellTranslation
                    }else{
                        xOffset = 0
                    }
                }
                
            } else if xOffset < kMaxCellTranslation / 2 && xOffset > -kMaxCellTranslation / 2 {
                
                xOffset = 0
                
            } else {
                
                if UserDefaults.isUserLoggedIn() == false && currentLang == "ar" {
                    xOffset = 0
                }else{
                    xOffset = -kMaxCellTranslation
                }
            }
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                
              //  self.mainContainer.transform = CGAffineTransform(translationX: xOffset, y: 0)
                self.currentTranslation = xOffset
            })

        default:
            break
        }
    }

    // MARK: Actions
    
    @IBAction func onEditButtonClick(_ sender: AnyObject) {
        
        self.delegate?.dashboardLocationCellDidTouchEditButton(self)
    }
    
    @IBAction func onDeleteButtonClick(_ sender: AnyObject) {
        
        self.delegate?.dashboardLocationCellDidTouchDeleteButton(self)
    }
    
}
