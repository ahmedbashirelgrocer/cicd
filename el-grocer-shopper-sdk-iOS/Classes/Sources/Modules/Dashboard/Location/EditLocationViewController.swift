//
//  EditLocationViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 23/07/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GooglePlaces
import DoneCancelNumberPadToolbar
import IQKeyboardManagerSwift
import GrowingTextView
enum editLocationState {
    
    case isForSignUp
    case isFromEdit
    case isForAddNew
    case isFromCart
    
}


class EditLocationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate , NavigationBarProtocol{
    
    @IBOutlet var floorTopSpace: NSLayoutConstraint!
    @IBOutlet var floorHeight: NSLayoutConstraint!
    
    var editScreenState : editLocationState = .isForAddNew
    @IBOutlet var editTableView: UITableView!
    @IBOutlet weak var editLocSView: UIScrollView!
    @IBOutlet weak var editAddressView: UIView! {
        didSet {
            editAddressView.backgroundColor = .textfieldBackgroundColor()
        }
    }
    @IBOutlet var lblTopMessage: UILabel!
    
    @IBOutlet var lbl_LocationInfo: UILabel! {
        
        didSet{
            lbl_LocationInfo.text = localizedString("lbl_location_info", comment: "")
        }
        
    }
    
//    @IBOutlet weak var tableView: UITableView!
//
//    @IBOutlet weak var searchTextField: UITextField!
//    @IBOutlet weak var searchView: UIView!
//
//    @IBOutlet weak var locationLabel: UILabel!
//    @IBOutlet weak var locationView: UIView!
//    @IBOutlet weak var locationImgView: UIImageView!
//
//    @IBOutlet weak var noCoverageTitleLabel: UILabel!
//    @IBOutlet weak var emailTextField: UITextField!
//    @IBOutlet weak var emailDoneButton: UIButton!
//    @IBOutlet weak var noCoverageView: UIView!
//
//    @IBOutlet weak var tableViewTopToSearchView: NSLayoutConstraint!
//    @IBOutlet weak var tableViewTopToLocationView: NSLayoutConstraint!
//
//    @IBOutlet weak var editLocScrollViewTopToSearchView: NSLayoutConstraint!
//    @IBOutlet weak var editLocScrollViewTopToLocationView: NSLayoutConstraint!
    
    @IBOutlet weak var apartmentViewTopToSuperView: NSLayoutConstraint!
    @IBOutlet weak var apartmentViewTopToFloorView: NSLayoutConstraint!
    
//    @IBOutlet weak var noCoverageViewTopToSearchView: NSLayoutConstraint!
//
//    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var apartmentLabel: UILabel!
    @IBOutlet weak var apartmentView: UIView! {
        didSet {
            apartmentView.backgroundColor = UIColor.navigationBarWhiteColor()
        }
    }
    @IBOutlet weak var apartmentImgView: UIImageView!
    var apartmentBtn = UIButton()
    
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var houseView: UIView! {
        didSet {
            houseView.backgroundColor = UIColor.navigationBarWhiteColor()
        }
    }
    @IBOutlet weak var houseImgView: UIImageView!
    var houseBtn = UIButton()
    
    @IBOutlet weak var officeLabel: UILabel!
    @IBOutlet weak var officeView: UIView! {
        didSet {
            officeView.backgroundColor = UIColor.navigationBarWhiteColor()
        }
    }
    @IBOutlet weak var officeImgView: UIImageView!
    var officeBtn = UIButton()
    
    @IBOutlet weak var buildingView: UIView! {
        didSet {
            buildingView.backgroundColor = UIColor.textfieldBackgroundColor()
        }
    }
    @IBOutlet weak var floorView: UIView! {
        didSet {
            buildingView.backgroundColor = UIColor.textfieldBackgroundColor()
        }
    }
    
    @IBOutlet weak var locNameTextField: UITextField! {
        
        didSet {
            self.locNameTextField.placeholder = localizedString("lbl_Map_Selection", comment: "")
            self.locNameTextField.attributedPlaceholder = NSAttributedString.init(string: self.locNameTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor()])
        }
        
    }
    
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var buildingTextField: ElgrocerTextField! {
        didSet {
            buildingTextField.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        }
    }
    
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var floorTextField: ElgrocerTextField! {
        didSet {
            floorTextField.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        }
    }
    
    @IBOutlet weak var apartmentNumberLabel: UILabel!
    @IBOutlet weak var apartmentNumberTextField: ElgrocerTextField! {
        didSet {
            apartmentNumberTextField.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        }
    }
    
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var streetTextField: ElgrocerTextField! {
        didSet {
            streetTextField.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        }
    }
    
    @IBOutlet weak var additionalDirectionLabel: UILabel!
    @IBOutlet weak var additionalDirectionTextField: ElgrocerTextField! {
        didSet {
//            additionalDirectionTextField.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        }
    }
    @IBOutlet var additionalDirectionTextView: GrowingTextView! {
        didSet {
            additionalDirectionTextView.backgroundColor = UIColor.navigationBarWhiteColor()
        }
    }
    @IBOutlet var addtionaltextviewClearButton: UIButton!
    
    
    @IBOutlet weak var limitLabel: UILabel!
    
    @IBOutlet weak var updateButton: UIButton!
    
    
    @IBOutlet var locationView: AWView! 
    @IBOutlet var apartmenttxtView: AWView! {
        didSet {
            apartmenttxtView.backgroundColor = UIColor.textfieldBackgroundColor()
        }
    }
    
    @IBOutlet var streetView: AWView! {
        didSet {
            streetView.backgroundColor = UIColor.textfieldBackgroundColor()
        }
    }
    
    
    var activeTextField: UITextField!
    
    var deliveryAddress: DeliveryAddress!
    var deliveryAddressLocation: CLLocation?
    
    var addressType = "0"
    var houseNumber = ""
    var apartmentNumber = ""
    
    var locationAddress = ""

    var isNoCoverage:Bool = false
    
    var searchString:String = ""
    
    var locShopId:NSNumber = 0.0
    
    var fetcher: GMSAutocompleteFetcher?
    
    let viewModel = LocationMapViewModel()
    
    var predictionsArray: [GMSAutocompletePrediction] = [GMSAutocompletePrediction]()
    
    
    var addressTag : NSArray = [NSDictionary]() as NSArray
    var selectIndexPath : NSIndexPath  = NSIndexPath.init(row: 0, section: 0)

    // MARK: Life cycle
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
        
        
        
        
        registerCell()
        setUpSearchTextFieldAppearance()
        showViewAccordingToLocationService()
        //setUpTextFieldConstraints()
        setupTableViewAppearance()
        setupNoCoverageViewAppearance()
        setUpLabelAppearance()
        setUpTextFieldAppearance()
        setUpUpdateButtonAppearance()
        setLocationDataInView()
        setLabelTitles()
       // _ = validateLocationFields()
        
        NotificationCenter.default.addObserver(self,selector: #selector(EditLocationViewController.showViewAccordingToLocationService), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
        IQKeyboardManager.shared.toolbarBarTintColor = .white
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self
//            .keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        let isServiceEnabled = self.checkLocationService()
        if isServiceEnabled {
            
            print("Current Location is enabled")
            
            if let location = LocationManager.sharedInstance.currentLocation.value {
                
                let lat = location.coordinate.latitude
                let long = location.coordinate.longitude
                let offset = 200.0 / 1000.0;
                let latMax = lat + offset;
                let latMin = lat - offset;
                let lngOffset = offset * cos(lat * .pi / 200.0);
                let lngMax = long + lngOffset;
                let lngMin = long - lngOffset;
                let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
                let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
                
                //let bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
                
                // Set up the autocomplete filter.
                let filter = GMSAutocompleteFilter()
                //filter.type = .Geocode
                
                if !(LocationManager.sharedInstance.countryCode == nil){
                    filter.country = LocationManager.sharedInstance.countryCode
                }
                filter.locationBias  = GMSPlaceRectangularLocationOption(initialLocation, otherLocation)
                // Create the fetcher.
                self.fetcher = GMSAutocompleteFetcher( filter: filter)
                self.fetcher?.delegate = self
                print("Fetcher is init with bounds")
                
            }else{
                print("Current Location is enabled but Fetcher is init without bounds")
                self.fetcher = GMSAutocompleteFetcher()
                self.fetcher?.delegate = self
            }
            
        }else{
            print("Current Location is not enabled so Fetcher is init without bounds")
            self.fetcher = GMSAutocompleteFetcher()
            self.fetcher?.delegate = self
        }
        
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.hidesBackButton = true
        (self.navigationController as? ElGrocerNavigationController)?.navigationBar.tintColor = .navigationBarColor()
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        
      //  self.perform(#selector(EditLocationViewController.scrollToLast), with: self, afterDelay: 1.0)
        
        if editScreenState == .isForSignUp {
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            self.addBackButtonWithCrossIconRightSide()
            self.title = localizedString("Sign_up", comment: "")
            self.lblTopMessage.text = localizedString("lbl_add_Address_msg", comment: "")
        }else if editScreenState == .isForAddNew {
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            self.title = localizedString("add_address_alert_title", comment: "")
             self.lblTopMessage.text = localizedString("lbl_add_Address_msg", comment: "")
        }else if editScreenState == .isFromEdit {
            // self.navigationItem.hidesBackButton = true
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
             self.title = localizedString("dashboard_location_edit_location_title", comment: "")
             self.lblTopMessage.text = localizedString("lbl_Edit_Address_msg", comment: "")
        }else {
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            self.navigationItem.hidesBackButton = true
            self.addBackButtonWithCrossIconRightSide()
            self.title = localizedString("dashboard_location_edit_location_title", comment: "")
            self.lblTopMessage.text = localizedString("lbl_Edit_Address_msg", comment: "")
        }
        self.navigationItem.backBarButtonItem?.title = ""
        
        if self.addressType == "1"{
            setTableViewHeader(540)
        } else {
            setTableViewHeader()
        }
        
        
        if addressTag.count == 0 {
            ElGrocerApi.sharedInstance.getaddressTag { (result, data) in
                if result {
                   if let dataA =  (data?["data"] as? NSDictionary)?["address_tags"] as? NSArray {
                         self.addressTag = dataA
                    for (index , data) in self.addressTag.enumerated() {
                        if data is NSDictionary {
                            if "\((data as! NSDictionary)["id"] ?? "")" == "\(self.deliveryAddress.addressTagId ?? "-1")"  {
                                self.selectIndexPath = NSIndexPath.init(row: index , section: 0)
                            }
                        }
                    }
                }
            }
                self.editTableView.reloadData()
         }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsEditLocationScreen)
        FireBaseEventsLogger.setScreenName(kGoogleAnalyticsEditLocationScreen, screenClass: String(describing: self.classForCoder))
    }
    

    @objc
    func scrollToLast() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0 , section: 0)
            self.editTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func setTableViewHeader(_ height : Int? = 680 ) {
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            self.editAddressView.clipsToBounds = true
            self.editAddressView.setNeedsLayout()
            self.editAddressView.layoutIfNeeded()
            self.editTableView.tableHeaderView = self.editAddressView
            
            if let headerView = self.editTableView.tableHeaderView {
                let headerViewFrame = headerView.frame
                var newRect = CGRect.init(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.size.width , height: headerView.frame.size.height)
                if height != nil {
                    newRect.size = CGSize.init(width: headerView.frame.size.width , height: CGFloat(height!))
                }
                headerView.frame = newRect
                self.editTableView.tableHeaderView = headerView
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Appearance
    
    func setUpLabelAppearance() {
    }
    
    func setUpTextFieldAppearance() {
        
        self.setUpLocationNameTextFieldAppearance()
        self.setUpBuildingTextFieldAppearance()
        self.setUpFloorTextFieldAppearance()
        self.setUpApartmentNumberTextFieldAppearance()
        self.setUpStreetTextFieldAppearance()
        self.setUpAdditionalDirectionTextFieldAppearance()
    }
    
    fileprivate func setUpLocationNameTextFieldAppearance() {
        
      //  self.locNameTextField.font = UIFont.bookFont(15.0)
       // self.locNameTextField.textColor = UIColor.darkTextGrayColor()
        self.locNameTextField.addTarget(self, action: #selector(EditLocationViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        let toolBar = DoneCancelNumberPadToolbar(textField: self.locNameTextField, withKeyboardType:Int32(self.locNameTextField.keyboardType.rawValue))
        toolBar?.delegate = self
        toolBar?.barStyle = UIBarStyle.default
        self.locNameTextField.inputAccessoryView = toolBar
    }
    
    fileprivate func setUpBuildingTextFieldAppearance() {
        
        
        self.buildingTextField.placeholder = localizedString("lbl_building", comment: "")
        
          self.buildingTextField.attributedPlaceholder = NSAttributedString.init(string: self.buildingTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor()])
        
     //   self.buildingTextField.font = UIFont.mediumFont(15.0)
        self.buildingTextField.textColor = UIColor.black
        
        
        let toolBar = DoneCancelNumberPadToolbar(textField: self.buildingTextField, withKeyboardType:Int32(self.buildingTextField.keyboardType.rawValue))
        toolBar?.delegate = self
        toolBar?.barStyle = UIBarStyle.default
        self.buildingTextField.inputAccessoryView = toolBar
    }
    
    fileprivate func setUpFloorTextFieldAppearance() {
        
        self.floorTextField.placeholder = localizedString("lbl_Floor", comment: "")
         self.floorTextField.attributedPlaceholder = NSAttributedString.init(string: self.floorTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor()])
        
    //    self.floorTextField.font = UIFont.mediumFont(15.0)
        self.floorTextField.textColor = UIColor.black
        
        
        let toolBar = DoneCancelNumberPadToolbar(textField: self.floorTextField, withKeyboardType:Int32(self.floorTextField.keyboardType.rawValue))
        toolBar?.delegate = self
        toolBar?.barStyle = UIBarStyle.default
        self.floorTextField.inputAccessoryView = toolBar
    }
    
    fileprivate func setUpApartmentNumberTextFieldAppearance() {
        
        self.apartmentNumberTextField.placeholder = localizedString("lbl_Apartment", comment: "")
         self.apartmentNumberTextField.attributedPlaceholder = NSAttributedString.init(string: self.apartmentNumberTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor()])
        
       // self.apartmentNumberTextField.font = UIFont.mediumFont(15.0)
        self.apartmentNumberTextField.textColor = UIColor.black
       
        
        let toolBar = DoneCancelNumberPadToolbar(textField: self.apartmentNumberTextField, withKeyboardType:Int32(self.apartmentNumberTextField.keyboardType.rawValue))
        toolBar?.delegate = self
        toolBar?.barStyle = UIBarStyle.default
        self.apartmentNumberTextField.inputAccessoryView = toolBar
    }
    
    fileprivate func setUpStreetTextFieldAppearance() {
        
        self.streetTextField.placeholder = localizedString("lbl_AreaStreet", comment: "")
          self.streetTextField.attributedPlaceholder = NSAttributedString.init(string: self.streetTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor()])
     //   self.streetTextField.font = UIFont.mediumFont(15.0)
        self.streetTextField.textColor = UIColor.black
      
        let toolBar = DoneCancelNumberPadToolbar(textField: self.streetTextField, withKeyboardType:Int32(self.streetTextField.keyboardType.rawValue))
        toolBar?.delegate = self
        toolBar?.barStyle = UIBarStyle.default
        self.streetTextField.inputAccessoryView = toolBar
    }
    
    fileprivate func setUpAdditionalDirectionTextFieldAppearance() {
        
        self.additionalDirectionTextField.placeholder = localizedString("lbl_placeholder_text", comment: "")
        
         self.additionalDirectionTextField.attributedPlaceholder = NSAttributedString.init(string: self.additionalDirectionTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor()])
        
        
        self.additionalDirectionTextView.attributedPlaceholder =  NSAttributedString.init(string: self.additionalDirectionTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor() , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14)])
        
     //   self.additionalDirectionTextField.font = UIFont.mediumFont(15.0)
        self.additionalDirectionTextField.textColor = UIColor.newBlackColor()
        self.additionalDirectionTextView.textColor = UIColor.newBlackColor()
        
        let toolBar = DoneCancelNumberPadToolbar(textField: self.additionalDirectionTextField, withKeyboardType:Int32(self.additionalDirectionTextField.keyboardType.rawValue))
        toolBar?.delegate = self
        toolBar?.barStyle = UIBarStyle.default
        self.additionalDirectionTextField.inputAccessoryView = toolBar
    }
    
    func setUpUpdateButtonAppearance() {
        
      //  self.updateButton.titleLabel!.font = UIFont.mediumFont(18.0)
        self.updateButton.setTitleColor(UIColor.white, for: UIControl.State())
        self.updateButton.setTitle(localizedString("force_update_button_title", comment: ""), for:UIControl.State())
        self.updateButton.setBackgroundColor(UIColor.navigationBarColor(), forState: UIControl.State())
        
        self.updateButton.layer.cornerRadius = 5.0
        self.updateButton.clipsToBounds = true
    }
    
    func setUpApartmentViewViewAppearanceWithSelection(_ isSelected:Bool) {
//
//        self.floorHeight.constant = 0
//        self.floorTopSpace.constant = 0
        self.apartmentView.layer.cornerRadius = 8
        self.apartmentView.layer.borderWidth = isSelected ? 2 : 0
        self.apartmentView.backgroundColor = isSelected ? UIColor.white : UIColor.navigationBarWhiteColor()
     //   self.apartmentLabel.font = UIFont.mediumFont(9.0)
        apartmentBtn.isSelected = isSelected
        
        if isSelected {
            self.apartmentView.layer.borderColor = UIColor.navigationBarColor().cgColor
            self.apartmentLabel.textColor = UIColor.navigationBarColor()
            self.apartmentImgView.image = UIImage(name: "Apartment")
            self.apartmentImgView.changePngColorTo(color: .navigationBarColor())
//            if let image = self.houseImgView.image?.withRenderingMode(.alwaysTemplate) {
//                self.houseImgView.image = image
//                self.houseImgView.tintColor = .navigationBarColor()
//            }
        }else{
            self.apartmentView.layer.borderColor = UIColor.borderGrayColor().cgColor
            self.apartmentLabel.textColor = .selectionTabDark()
            self.apartmentImgView.image = UIImage(name: "Apartment")
            self.apartmentImgView.changePngColorTo(color: .selectionTabDark())
//            if let image = self.houseImgView.image?.withRenderingMode(.alwaysTemplate) {
//                self.houseImgView.image = image
//                self.houseImgView.tintColor = .selectionTabDark()
//            }
        }
        
       
        self.editAddressView.setNeedsLayout()
        self.editAddressView.layoutIfNeeded()
    }
    
    func setUpHouseViewViewAppearanceWithSelection(_ isSelected:Bool) {
        
        self.floorHeight.constant = 56
        self.floorTopSpace.constant = 20//16
        
        self.houseView.layer.cornerRadius = 8
        self.houseView.layer.borderWidth = isSelected ? 2 : 0
        self.houseView.backgroundColor = isSelected ? UIColor.white : UIColor.navigationBarWhiteColor()
      ///  self.houseLabel.font = UIFont.mediumFont(9.0)
        houseBtn.isSelected = isSelected
        
        if isSelected {
            self.houseView.layer.borderColor = UIColor.navigationBarColor().cgColor
            self.houseLabel.textColor = UIColor.navigationBarColor()
            self.houseImgView.image = UIImage(name: "House")
            self.houseImgView.changePngColorTo(color: .navigationBarColor())
        }else{
            self.houseView.layer.borderColor = UIColor.borderGrayColor().cgColor
            self.houseLabel.textColor = .selectionTabDark()
            self.houseImgView.image = UIImage(name: "House")
            self.houseImgView.changePngColorTo(color: .selectionTabDark())
            
        }
    }
    
    func setUpOfficeViewViewAppearanceWithSelection(_ isSelected:Bool) {
        
        self.floorHeight.constant = 56
        self.floorTopSpace.constant = 20//16
        self.officeView.layer.cornerRadius = 8
        self.officeView.layer.borderWidth = isSelected ? 2 : 0
        self.officeView.backgroundColor = isSelected ? UIColor.white : UIColor.navigationBarWhiteColor()
       
        
      //  self.officeLabel.font = UIFont.mediumFont(9.0)
        officeBtn.isSelected = isSelected
        
        if isSelected {
            self.officeView.layer.borderColor = UIColor.navigationBarColor().cgColor
            self.officeLabel.textColor = UIColor.navigationBarColor()
            self.officeImgView.image = UIImage(name: "Office")
            self.officeImgView.changePngColorTo(color: .navigationBarColor())
//            if let image = self.houseImgView.image?.withRenderingMode(.alwaysTemplate) {
//                self.houseImgView.image = image
//                self.houseImgView.tintColor = .navigationBarColor()
//            }
        }else{
            self.officeView.layer.borderColor = UIColor.borderGrayColor().cgColor
            self.officeLabel.textColor = .selectionTabDark()
            self.officeImgView.image = UIImage(name: "Office")
            self.officeImgView.changePngColorTo(color: .selectionTabDark())
//            if let image = self.houseImgView.image?.withRenderingMode(.alwaysTemplate) {
//                self.houseImgView.image = image
//                self.houseImgView.tintColor = .selectionTabDark()
//            }
        }
    }
    
    func setUpSearchTextFieldAppearance(){
        
//        self.searchTextField.placeholder = localizedString("dashboard_location_search_placeholder", comment: "")
//        self.searchTextField.font = UIFont.bookFont(13.0)
//        self.searchTextField.textColor = UIColor.darkTextGrayColor()
//        self.searchTextField.backgroundColor = UIColor.lightGrayBGColor()
//
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.searchTextField.frame.height))
//        self.searchTextField.leftView = paddingView
//        self.searchTextField.leftViewMode = UITextField.ViewMode.always
    }
    
    func setUpLocationViewAppearance(_ isEnabled:Bool){
        
        var titleStr = NSMutableAttributedString()
        
        if isEnabled {
//            self.locationView.backgroundColor =  UIColor.meunCellSelectedColor()
//            self.locationImgView.image = UIImage(name: "location-pin-selected")
//            self.locationLabel.textColor = UIColor.meunGreenTextColor()
            
            titleStr = NSMutableAttributedString(string: localizedString("dashboard_enable_location_services", comment: ""))
            
        }else{
//            self.locationView.backgroundColor =  UIColor.redInfoColor()
//            self.locationImgView.image = UIImage(name: "location-pin-white")
//            self.locationLabel.textColor = UIColor.white
//
            titleStr = NSMutableAttributedString(string: localizedString("dashboard_enable_location_services_2", comment: ""))
        }
        
//        self.locationLabel.font = UIFont.mediumFont(13.0)
//        self.locationLabel.numberOfLines = 0
//        self.locationLabel.sizeToFit()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.0
        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
     //   self.locationLabel.attributedText = titleStr
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditLocationViewController.onEnableLocationClick))
     self.locationView.addGestureRecognizer(tapGesture)
    
    }
    
    func setupTableViewAppearance() {
        self.editTableView.backgroundColor = .white
    }
    
    func setupNoCoverageViewAppearance() {
        
        let tapGesture  = UITapGestureRecognizer(target: self,action:#selector(EditLocationViewController.handleTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
//        self.noCoverageView.addGestureRecognizer(tapGesture)
//
//        self.noCoverageTitleLabel.font = UIFont.bookFont(12.0)
//        self.noCoverageTitleLabel.textColor = UIColor.black
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        let titleStr = NSMutableAttributedString(string: localizedString("txt_not_cover_area_1", comment: ""))
        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
        
//        self.noCoverageTitleLabel.attributedText = titleStr
//
//        self.noCoverageTitleLabel.numberOfLines = 0
//        self.noCoverageTitleLabel.sizeToFit()
//
//        self.emailDoneButton.titleLabel!.font = UIFont.mediumFont(18.0)
//        self.emailDoneButton.setTitleColor(UIColor.white, for: UIControl.State())
//        self.emailDoneButton.setTitle(localizedString("delivery_note_done_button_title", comment: ""), for:UIControl.State())
//        self.emailDoneButton.setBackgroundColor(UIColor.navigationBarColor(), forState: UIControl.State())
//
//        self.emailDoneButton.layer.cornerRadius = 5.0
//        self.emailDoneButton.clipsToBounds = true
        setEmailDoneButtonEnabled(false)
        
//        self.emailTextField.placeholder = localizedString("enter_email_placeholder_text", comment: "")
//        self.emailTextField.font = UIFont.bookFont(13.0)
//        self.emailTextField.textColor = UIColor.darkTextGrayColor()
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if(userProfile != nil){
             //   self.emailTextField.text = userProfile?.email
                _ = self.validateEmail((userProfile?.email)!)
            }
        }
    }
    
    // MARK: TapGesture
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        
       // self.emailTextField.resignFirstResponder()
    }
    
    // MARK: Validations
    
    func validateEmail(_ email:String) -> Bool {
        
        let enableSubmitButton = email.isValidEmail()
        
      //  self.emailTextField.layer.borderColor = (!enableSubmitButton && !email.isEmpty) ? UIColor.redValidationErrorColor().cgColor : UIColor.borderGrayColor().cgColor
        
        setEmailDoneButtonEnabled(enableSubmitButton)
        
        return enableSubmitButton
    }
    
    func setEmailDoneButtonEnabled(_ enabled:Bool) {
        
      //  self.emailDoneButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
       //     self.emailDoneButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    func validateLocationFields() -> Bool {
        
        var enableSubmitButton = false
        
        if self.addressType == "1" {
            enableSubmitButton = !self.locNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.apartmentNumberTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.streetTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.addressType.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && self.deliveryAddressLocation != nil
        }else{
           
         enableSubmitButton = !self.locNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            && !self.buildingTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            && !self.floorTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            && !self.apartmentNumberTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            && !self.streetTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            && !self.addressType.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            && self.deliveryAddressLocation != nil
            
            
            if self.floorTextField.text!.count == 0 {
                //self.floorView.layer.borderWidth = 1
                //self.floorView.layer.borderColor = UIColor.redInfoColor().cgColor
                self.floorTextField.showError(message: localizedString("error_enter_Floor", comment: ""))
            }else{
                self.floorView.layer.borderWidth = 0
            }
            
            if self.buildingTextField.text!.count == 0 {
                //self.buildingView.layer.borderWidth = 1
                //self.buildingView.layer.borderColor = UIColor.redInfoColor().cgColor
                self.buildingTextField.showError(message: localizedString("error_enter_building", comment: ""))
            }else{
                self.buildingView.layer.borderWidth = 0
            }
        }
        
        
        if self.locNameTextField.text!.count == 0 {
            self.locationView.layer.borderWidth = 1
            self.locationView.layer.borderColor = UIColor.redInfoColor().cgColor
        }else{
            self.locationView.layer.borderWidth = 1
            self.locationView.layer.borderColor = UIColor.lightGrayBGColor().cgColor
        }
        
        if self.apartmentNumberTextField.text!.count == 0 {
            //self.apartmenttxtView.layer.borderWidth = 1
            //self.apartmenttxtView.layer.borderColor = UIColor.redInfoColor().cgColor
            self.apartmentNumberTextField.showError(message: localizedString("error_enter_apartment", comment: ""))
        }else{
            self.apartmenttxtView.layer.borderWidth = 0
        }
        
        if self.streetTextField.text!.count == 0 {
            //self.streetView.layer.borderWidth = 1
           // self.streetView.layer.borderColor = UIColor.redInfoColor().cgColor
            self.streetTextField.showError(message: localizedString("error_enter_street", comment: ""))
        }else{
            self.streetView.layer.borderWidth = 0
        }
    
        setUpdateButtonEnabled(true)
        self.editTableView.reloadData()
        
        if let cell = self.editTableView.cellForRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath)  {
            if let current  =  cell as? LocationPersonalInfoTableViewCell {
                
                if current.txtMobileNumber.text?.count == 0 {
                    //current.viewPhoneNumber.layer.borderWidth = 1
                    //current.viewPhoneNumber.layer.borderColor = UIColor.redValidationErrorColor().cgColor
                    current.txtMobileNumber.showError(message: "Please enter your mobile number.")
                    enableSubmitButton = false
                }
                if current.txtShopperName.text?.count == 0 {
                    //current.viewName.layer.borderWidth = 1
                    //current.viewName.layer.borderColor = UIColor.redValidationErrorColor().cgColor
                    current.txtMobileNumber.showError(message: "Please enter your mobile number.")
                    enableSubmitButton = false
                }
               
            }
        }
        
        return enableSubmitButton
    }
    
    
    func updateBorderAccordingToTextfield(_ textField : UITextField) {
        
        if textField == self.floorTextField {
        if self.floorTextField.text!.count == 0 {
           // self.floorView.layer.borderWidth = 1
            self.floorView.layer.borderColor = UIColor.redInfoColor().cgColor
        }else{
            self.floorView.layer.borderWidth = 0
        }
        }
        
        
        if textField == self.buildingTextField {
            if self.buildingTextField.text!.count == 0 {
               // self.buildingView.layer.borderWidth = 1
                self.buildingView.layer.borderColor = UIColor.redInfoColor().cgColor
            }else{
                self.buildingView.layer.borderWidth = 0
            }
            
        }
        if textField == self.locNameTextField {
            if self.locNameTextField.text!.count == 0 {
                self.locationView.layer.borderWidth = 1
                self.locationView.layer.borderColor = UIColor.redInfoColor().cgColor
            }else{
                self.locationView.layer.borderWidth = 1
                self.locationView.layer.borderColor = UIColor.lightGrayBGColor().cgColor
            }
            
            
        }
        if textField == self.apartmentNumberTextField {
            if self.apartmentNumberTextField.text!.count == 0 {
                //self.apartmenttxtView.layer.borderWidth = 1
                self.apartmenttxtView.layer.borderColor = UIColor.redInfoColor().cgColor
            }else{
                self.apartmenttxtView.layer.borderWidth = 0
            }
            
            
        }
        if textField == self.streetTextField {
            if self.streetTextField.text!.count == 0 {
                //self.streetView.layer.borderWidth = 1
                self.streetView.layer.borderColor = UIColor.redInfoColor().cgColor
            }else{
                self.streetView.layer.borderWidth = 0
            }
            
        }
         
    }
    
    func setUpdateButtonEnabled(_ enabled:Bool) {
        
        self.updateButton.enableWithAnimation(enabled)
        
//        self.updateButton.isEnabled = enabled
//
//        UIView.animate(withDuration: 0.33, animations: { () -> Void in
//
//            self.updateButton.alpha = enabled ? 1 : 0.3
//        })
    }
    
    // MARK: Enable location
    @objc func onEnableLocationClick() {
        
        ElGrocerAlertView.createAlert(localizedString("dashboard_enable_location_alert_title", comment: ""),
                                      description: localizedString("dashboard_enable_location_services_3", comment: ""),
                                      positiveButton: localizedString("sign_out_alert_yes", comment: ""),
                                      negativeButton: localizedString("sign_out_alert_no", comment: ""),
                                      buttonClickCallback: { (buttonIndex:Int) -> Void in
                                        
                                        if buttonIndex == 0 {
                                            print("Yes Tapped")
                                            UIApplication.shared.openURL(URL(string:UIApplication.openSettingsURLString)!)
                                        }else{
                                            self.setUpLocationViewAppearance(false)
                                        }
        }).show()
    }
    
    // MARK: Check Location Services
    
    @objc func showViewAccordingToLocationService(){
        
       // hideLocationView(false)
        setUpLocationViewAppearance(true)
        
//        let isServiceEnabled = self.checkLocationService()
//        if isServiceEnabled {
//            hideLocationView(true)
//        }else{
//            hideLocationView(false)
//            setUpLocationViewAppearance(true)
//        }
    }
    
    func checkLocationService() -> Bool {
        
        var isCurrentLocationEnabled = false
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                print("No Access to Location services")
                isCurrentLocationEnabled = false
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Have Location services Access")
                isCurrentLocationEnabled = true
                @unknown default:
                print("location defaurl")
            }
        }
        
        return isCurrentLocationEnabled
    }
    
    // MARK: Hide Location View
    fileprivate func hideLocationView(_ hidden:Bool){
        
      //  locationView.isHidden = hidden
        
//     //   tableViewTopToSearchView.constant = hidden ? 0 : 60
//        tableViewTopToSearchView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
//        tableViewTopToLocationView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
//        
//        editLocScrollViewTopToSearchView.constant = hidden ? 0 : 60
//        editLocScrollViewTopToLocationView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
//        editLocScrollViewTopToSearchView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    fileprivate func hideBuildingAndApartmentView(_ hidden:Bool){
        
        buildingView.isHidden = hidden
        floorView.isHidden = hidden
        
        apartmentViewTopToSuperView.constant = hidden ? 0 : 110
        apartmentViewTopToSuperView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        apartmentViewTopToFloorView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    // MARK: Data
    
    func setLocationDataInView() {
        
        self.apartmentLabel.text = localizedString("apartment", comment: "")
        self.houseLabel.text = localizedString("house", comment: "")
        self.officeLabel.text = localizedString("office", comment: "")
        
        self.deliveryAddressLocation = CLLocation(latitude: self.deliveryAddress.latitude, longitude: self.deliveryAddress.longitude)
    
        self.locationAddress =  self.deliveryAddress.address
        
        if self.deliveryAddress.locationName != ""{
            self.locNameTextField.text = self.deliveryAddress.locationName
        }
        if self.deliveryAddress.street != ""{
            self.streetTextField.text = self.deliveryAddress.street
            self.streetTextField.resignFirstResponder()
        }
        if self.deliveryAddress.building != ""{
            self.buildingTextField.text = self.deliveryAddress.building
            self.buildingTextField.resignFirstResponder()

        }
        if self.deliveryAddress.floor != ""{
            self.floorTextField.text = self.deliveryAddress.floor
            self.floorTextField.resignFirstResponder()

        }
        if self.deliveryAddress.additionalDirection != ""{
            self.additionalDirectionTextField.text = self.deliveryAddress.additionalDirection
            self.additionalDirectionTextView.text = self.deliveryAddress.additionalDirection
            
            self.additionalDirectionTextField.resignFirstResponder()

        }
        
         self.apartmentNumber = self.deliveryAddress.apartment!
        
        if self.deliveryAddress.additionalDirection != nil {
            self.limitLabel.text = String(format: "%d/100",(self.deliveryAddress.additionalDirection?.count)!)
        }else{
            self.limitLabel.text = "0/100"
        }
        
        if self.deliveryAddress.houseNumber != nil {
            self.houseNumber = self.deliveryAddress.houseNumber!
        }
        
        self.addressType = self.deliveryAddress.addressType
        
        if self.addressType.isEmptyStr {
            self.addressType = "0"
        }
        
     
        if self.addressType == "0" {
            
            setUpApartmentViewViewAppearanceWithSelection(true)
            setUpHouseViewViewAppearanceWithSelection(false)
            setUpOfficeViewViewAppearanceWithSelection(false)
            
            self.hideBuildingAndApartmentView(false)
            if self.apartmentNumber != ""{
                self.apartmentNumberTextField.text = self.apartmentNumber
                self.apartmentNumberTextField.resignFirstResponder()

            }
            
           
            
        }else if self.addressType == "1"{
            
            setUpHouseViewViewAppearanceWithSelection(true)
            setUpApartmentViewViewAppearanceWithSelection(false)
            setUpOfficeViewViewAppearanceWithSelection(false)
            
            self.hideBuildingAndApartmentView(true)
            if self.houseNumber != ""{
                self.apartmentNumberTextField.text = self.houseNumber
                self.apartmentNumberTextField.resignFirstResponder()

            }
           
            
        }else{
            
            setUpOfficeViewViewAppearanceWithSelection(true)
            setUpApartmentViewViewAppearanceWithSelection(false)
            setUpHouseViewViewAppearanceWithSelection(false)
            
            self.hideBuildingAndApartmentView(false)
            if self.apartmentNumber != ""{
                self.apartmentNumberTextField.text =  self.apartmentNumber
                self.apartmentNumberTextField.resignFirstResponder()

            }
            
        }
    }
    
    func setLabelTitles() {
        
        self.buildingLabel.text = localizedString("building", comment: "")
        self.floorLabel.text = localizedString("floor", comment: "")
        
        if self.addressType == "0" {
             self.apartmentNumberLabel.text = localizedString("apartment_no", comment: "")
        }else if self.addressType == "1"{
             self.apartmentNumberLabel.text = localizedString("house", comment: "")
        }else{
            self.apartmentNumberLabel.text = localizedString("office_no", comment: "")
        }
        self.streetLabel.text = localizedString("street", comment: "")
        self.additionalDirectionLabel.text = localizedString("additional_direction", comment: "")
    }
    
    // MARK: UITableView
    
    
    func registerCell() {
        
        let genericBannersCell = UINib(nibName: "LocationPersonalInfoTableViewCell", bundle: Bundle(for: LocationPersonalInfoTableViewCell.self))
        self.editTableView.register(genericBannersCell, forCellReuseIdentifier: "LocationPersonalInfoTableViewCell")

    }
    
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.0
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 356 + 16 // 16 for top padding
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1 // self.predictionsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell:LocationPersonalInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LocationPersonalInfoTableViewCell", for: indexPath) as! LocationPersonalInfoTableViewCell
        cell.configureView(self.addressTag as! [Dictionary<String, Any>], index: self.selectIndexPath, editScreenState: self.editScreenState)
        cell.buttonClick = {[weak self] in
            self?.updateButtonHandler("")
        }
        cell.indexSelected = {[weak self] (ind) in
            self?.selectIndexPath = NSIndexPath.init(row: ind , section: 0)
        }
        if cell.txtShopperName.text?.count == 0 {
            cell.txtShopperName.text = self.deliveryAddress.shopperName
        }
        if cell.txtMobileNumber.text?.count == 0 {
            cell.txtMobileNumber.text = self.deliveryAddress.phoneNumber
        }
        
        cell.btnDone.enableWithAnimation(self.updateButton.isEnabled)
        
        //self.deliveryAddress.addressTagId
        //
        return cell
 
//
//        if (indexPath as NSIndexPath).row == self.predictionsArray.count{
//
//            let cell:AddAddressCell = tableView.dequeueReusableCell(withIdentifier: kAddAddressCellIdentifier, for: indexPath) as! AddAddressCell
//            cell.configureCell()
//            return cell
//
//        }else{
//
//            let prediction = self.predictionsArray[(indexPath as NSIndexPath).row]
//
//            let cell:LocationSearchCell = tableView.dequeueReusableCell(withIdentifier: kLocationSearchCellIdentifier, for: indexPath) as! LocationSearchCell
//
//            cell.configureWithPrediction(prediction)
//            return cell
//
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row == self.predictionsArray.count{
            
//            let locationMapController = ElGrocerViewControllers.locationMapViewController()
//            locationMapController.delegate = self
//            self.navigationController?.pushViewController(locationMapController, animated: true)

        }else{
            
            print("User Tap on any Prediction")
            
          //  self.searchTextField.text = ""
            self.searchString = ""
//            self.searchTextField.resignFirstResponder()
//            self.tableView.isHidden = true
            
            let prediction = self.predictionsArray[(indexPath as NSIndexPath).row]
            let placesClient = GMSPlacesClient()
            let placeID = prediction.placeID
            _ = SpinnerView.showSpinnerViewInView(self.view)
            placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    SpinnerView.hideSpinnerView()
                    return
                }
                
                guard let place = place else {
                    print("No place details for \(placeID)")
                    SpinnerView.hideSpinnerView()
                    return
                }
                
                let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                self.viewModel.selectedLocation.value = location
                self.viewModel.buildingName.value = ElGrocerUtility.sharedInstance.getPremiseFrom(place)
                
                print("Place name:%@",place.name as Any)
                self.viewModel.predictionlocationName.value = place.name
                self.viewModel.predictionlocationAddress.value = place.formattedAddress
                
                self.checkForCoveredArea()
            })
        
        }
    }
    
    func checkForCoveredArea(){
        
        guard let location = self.viewModel.selectedLocation.value else {
            SpinnerView.hideSpinnerView()
            return
        }
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.checkCoveredAreaForGroceries(location) { (result) -> Void in
            
            SpinnerView.hideSpinnerView()
            
            switch result {
                
            case .success(let response):
                
                print("Success")
                
                let dataDict = response["data"] as? NSDictionary
                let isCovered = dataDict!["is_covered"] as? Bool
                // IntercomeHelper.updateIsLiveToIntercom(isCovered!)
                // PushWooshTracking.updateIsLive(isCovered!)
                
                if(isCovered == true){
                    
                    guard let locName = self.viewModel.predictionlocationName.value else {return}
                    print("Location Name:%@",locName)
                    
                    guard let locAddress = self.viewModel.predictionlocationAddress.value else {return}
                    print("Location Address:%@",locAddress)
                    
                    self.editDeliveryAddressWithLocation(location, withLocationName: locName, andWithUserAddress: locAddress)
                    
                }else{
                    
                    self.locShopId =  dataDict!["location_without_shop_id"] as! NSNumber
                    print("ShopID:%@",self.locShopId)
                    self.isNoCoverage = true
                   // self.noCoverageView.isHidden = false
                }
                
            case .failure(let error):
                error.showErrorAlert()
                
            }
        }
    }
    
    // MARK: Refresh Data
    func refreshData() {
        
        if searchString.isEmpty {
            self.showViewAccordingToLocationService()
          //  self.tableView.isHidden = true
            self.editLocSView.isHidden = false
        }else{
        //    self.tableView.isHidden = false
            self.hideLocationView(true)
        }
       // self.tableView.reloadData()
    }
    
    // MARK: TextField Did Change
    @objc func textFieldDidChange(_ textField: UITextField){
      //  _ = self.validateLocationFields()
    }
    
    // MARK: TextField Actions
    @IBAction func textFieldTextChange(_ sender: AnyObject) {
        
        self.isNoCoverage = false
       // self.noCoverageView.isHidden = true
        
        self.editLocSView.isHidden = true
        
//        self.searchString = self.searchTextField.text!
//        self.fetcher?.sourceTextHasChanged(self.searchTextField.text!)
    }
    
    // MARK: Animation
    
    fileprivate func performBackAnimation() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    // MARK: Hide No Coverage View
    
    fileprivate func hideNoCoverageView(){
        self.performBackAnimation()
        self.isNoCoverage = false
     //   self.noCoverageView.isHidden = true
        self.refreshData()
    }
    
    // MARK: Edit Delivery Address
    func editDeliveryAddressWithLocation(_ selectedLocation:CLLocation, withLocationName locName:String, andWithUserAddress userAddress:String){
        
        self.deliveryAddressLocation = selectedLocation
        
        self.locNameTextField.text = locName
        self.locationAddress = userAddress
        
        self.editLocSView.isHidden = false
    }
    
    // MARK: Button Actions
    
    override func crossButtonClick() {
        self.backButtonClick()
    }
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    override func backButtonClick() {
        
        if isNoCoverage {
            self.hideNoCoverageView()
        }else{
//            if editScreenState == .isFromCart {
//                self.navigationController?.dismiss(animated: true, completion: nil)
//                return
//            }
            
            if self.navigationController?.viewControllers.count == 1 {
                if self.navigationController?.viewControllers[0] is EditLocationViewController {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
            }
           self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func emailDoneHandler(_ sender: AnyObject) {
        
    }
    
    @IBAction func apartmentHandler(_ sender: AnyObject) {
        
        apartmentBtn = sender as! UIButton
        apartmentBtn.isSelected = true
        setUpApartmentViewViewAppearanceWithSelection(true)
        setUpHouseViewViewAppearanceWithSelection(false)
        setUpOfficeViewViewAppearanceWithSelection(false)
        
        if self.addressType == "1" {
            self.houseNumber = self.apartmentNumberTextField.text!
        }else{
            self.apartmentNumber = self.apartmentNumberTextField.text!
        }
        
        self.addressType = "0"
        if self.apartmentNumber != ""{
            self.apartmentNumberTextField.text = self.apartmentNumber
        }
        
        
        self.hideBuildingAndApartmentView(false)
        self.setLabelTitles()
      //  _ = self.validateLocationFields()
        
        self.setTableViewHeader()
        
        self.apartmentNumberTextField.placeholder = localizedString("lbl_Apartment", comment: "")
//        self.floorTextField.placeholder = localizedString("lbl_Floor", comment: "")
//        self.streetTextField.placeholder =  localizedString("lbl_AreaStreet", comment: "")
    }
    
    @IBAction func houseHandler(_ sender: AnyObject) {
        
        houseBtn = sender as! UIButton
        houseBtn.isSelected = true
        setUpHouseViewViewAppearanceWithSelection(true)
        setUpApartmentViewViewAppearanceWithSelection(false)
        setUpOfficeViewViewAppearanceWithSelection(false)
        
        if self.addressType == "1" {
            self.houseNumber = self.apartmentNumberTextField.text!
        }else{
            self.apartmentNumber = self.apartmentNumberTextField.text!
        }
        
        self.addressType = "1"
        if self.houseNumber != ""{
            self.apartmentNumberTextField.text = self.houseNumber
            self.apartmentNumberTextField.resignFirstResponder()

        }
        
        
        self.hideBuildingAndApartmentView(true)
        self.setLabelTitles()
      //  _ = self.validateLocationFields()
        self.setTableViewHeader(540)
        
        
       self.apartmentNumberTextField.placeholder =  localizedString("houseTxt", comment: "")
        
        
    }
    
    func setUpTextFieldConstraints() {
        //self.floorView.topAnchor.constraint(equalTo: self.buildingTextField.lblError.bottomAnchor, constant: 5).isActive = true
        
        //self.apartmenttxtView.topAnchor.constraint(equalTo: self.floorTextField.lblError.bottomAnchor, constant: 12).isActive = true
        //self.streetView.topAnchor.constraint(equalTo: self.apartmentNumberTextField.lblError.bottomAnchor, constant: 12).isActive = true
        //self..topAnchor.constraint(equalTo: self.apartmentNumberTextField.lblError.bottomAnchor, constant: 12).isActive = true
    }
    
    @IBAction func officeHandler(_ sender: AnyObject) {
        
        officeBtn = sender as! UIButton
        officeBtn.isSelected = true
        setUpOfficeViewViewAppearanceWithSelection(true)
        setUpApartmentViewViewAppearanceWithSelection(false)
        setUpHouseViewViewAppearanceWithSelection(false)
        
        if self.addressType == "1" {
            self.houseNumber = self.apartmentNumberTextField.text!
        }else{
            self.apartmentNumber = self.apartmentNumberTextField.text!
        }
        
        self.addressType = "2"
        if self.apartmentNumber != ""{
            self.apartmentNumberTextField.text = self.apartmentNumber
            self.apartmentNumberTextField.resignFirstResponder()

        }
        
        
        self.hideBuildingAndApartmentView(false)
        self.setLabelTitles()
     //   _ = self.validateLocationFields()
          self.setTableViewHeader()
        
        self.apartmentNumberTextField.placeholder = localizedString("office_no", comment: "")
    }
    
    @IBAction func updateButtonHandler(_ sender: Any) {
        
        guard validateLocationFields() == true else {return}
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        self.editDeliveryAddress()
    }
    
    
    func editDeliveryAddress() {
        
        //set new data from view
        self.deliveryAddress.address = self.locationAddress
        
        self.deliveryAddress.locationName = self.locNameTextField.text!
        self.deliveryAddress.latitude =  self.deliveryAddressLocation!.coordinate.latitude
        self.deliveryAddress.longitude =  self.deliveryAddressLocation!.coordinate.longitude
        
        self.deliveryAddress.street = self.streetTextField.text
        self.deliveryAddress.building = self.buildingTextField.text
        self.deliveryAddress.floor = self.floorTextField.text
        self.deliveryAddress.additionalDirection = self.additionalDirectionTextField.text
        self.deliveryAddress.additionalDirection = self.additionalDirectionTextView.text
        
        if self.addressType == "1"{
            self.houseNumber = self.apartmentNumberTextField.text!
        }else{
            self.apartmentNumber = self.apartmentNumberTextField.text!
        }
        
        self.deliveryAddress.houseNumber = self.houseNumber
        self.deliveryAddress.apartment = self.apartmentNumber
        
        self.deliveryAddress.addressType = self.addressType
        
        
        if let cell = self.editTableView.cellForRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath)  {
            if let current  =  cell as? LocationPersonalInfoTableViewCell {
                self.deliveryAddress.phoneNumber = current.txtMobileNumber.text ?? ""
                self.deliveryAddress.shopperName =  current.txtShopperName.text ?? ""
                if  self.addressTag.count > self.selectIndexPath.row {
                    let obj =  self.addressTag[self.selectIndexPath.row]
                    if obj is NSDictionary {
                          self.deliveryAddress.addressTagId = "\(String(describing: ((obj as! NSDictionary)["id"]) ?? ""))"
                    }
                }
            }
        }
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if userProfile != nil {
            if userProfile?.name?.count == 0 {
                userProfile?.name =  self.deliveryAddress.shopperName
                self.AddUserAddressWithProfile(userProfile!)
            }
        }
        
   
        ElGrocerApi.sharedInstance.updateDeliveryAddress(self.deliveryAddress, completionHandler: { (result:Bool) -> Void in
            
            GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Edit)
            
            SpinnerView.hideSpinnerView()
            
            if result {
                
                DatabaseHelper.sharedInstance.saveDatabase()
                // IntercomeHelper.updateUserAddressInfoToIntercom()
                // PushWooshTracking.updateUserAddressInfo()
                
                if self.editScreenState == .isFromCart {
                    if  self.navigationController?.viewControllers[0] is MyBasketViewController {
                        self.navigationController?.popViewController(animated: true)
                        if ElGrocerUtility.sharedInstance.activeGrocery == nil {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KRefreshBasketNumberNotifcation) , object: nil , userInfo: nil)
                            guard let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) else {
                                SpinnerView.hideSpinnerView()
                                return
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
                            DynamicLinksHelper.sharedInstance.setNewGroceryAccordingToLink(currentAddress.dbID)
                            ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
                            SpinnerView.hideSpinnerView()
                            ElGrocerUtility.sharedInstance.delay(0.5) {
                                
                                self.tabBarController?.selectedIndex = 0
                            }
                           
                        }
                        return
                    }
                    self.dismiss(animated: true) { }
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
               
                
            } else {
                
                DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                
                ElGrocerAlertView.createAlert(localizedString("my_account_saving_error", comment: ""),
                    description: nil,
                    positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                    negativeButton: nil, buttonClickCallback: nil).show()
            }
        })
    }
    
    
    func AddUserAddressWithProfile(_ userProfile: UserProfile) {
  
        ElGrocerApi.sharedInstance.updateUserProfile(userProfile.name!, email: userProfile.email, phone: userProfile.phone!) { (result:Bool) -> Void in
             SpinnerView.hideSpinnerView()
        }
    }
    
    //MARK: KeyBoard Handling
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        if isNoCoverage{
            
            UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
             //   self.noCoverageViewTopToSearchView.constant = self.searchView.frame.height - keyboardHeight
                }, completion: { finished in
            })
            
        }else{
            
//            if activeTextField != self.searchTextField || activeTextField == self.locNameTextField {
//
//                UIView.animate(withDuration: 0.33, animations: { () -> Void in
//
//               //     self.scrollViewBottomSpaceConstraint.constant = keyboardHeight + 10
//                })
//
//                /*if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//
//                    self.scrollViewBottomSpaceConstraint.constant = CGFloat(keyboardSize.height + self.deliveryInfoView.frame.height)
//
//                    UIView.animateWithDuration(0.33, animations: { () -> Void in
//
//                        self.view.layoutIfNeeded()
//                    })
//                }*/
//            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if isNoCoverage{
            
//            UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
//                self.noCoverageViewTopToSearchView.constant = 0
//                }, completion: { finished in
//
//            })
            
        }else{
            
//            self.scrollViewBottomSpaceConstraint.constant = 0
//
//            UIView.animate(withDuration: 0.33, animations: { () -> Void in
//
//                self.view.layoutIfNeeded()
//            })
        }
    }
    
    @IBAction func addtionalTextViewClearbuttonHandler(_ sender: Any) {
        self.additionalDirectionTextView.text = ""
        self.additionalDirectionTextView.resignFirstResponder()
    }
}

// MARK: LocationMapViewControllerDelegate

extension EditLocationViewController: LocationMapViewControllerDelegate {
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String?, withBuilding building: String? , withCity cityName: String?) {
        self.editDeliveryAddressWithLocation(location!, withLocationName: name!, andWithUserAddress: building!)
        _ = self.validateLocationFields()
        self.navigationController?.popViewController(animated: true)
    }
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
        
        self.editDeliveryAddressWithLocation(location!, withLocationName: name!, andWithUserAddress: building!)
        _ = self.validateLocationFields()
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: UITextFieldDelegate
extension EditLocationViewController: UITextFieldDelegate , UITextViewDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeTextField = textField
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
//        if textField == self.searchTextField {
//            isNoCoverage = false
//        }
        
        if textField == self.locNameTextField {
            let locationMapController = ElGrocerViewControllers.locationMapViewController()
            locationMapController.delegate = self
            
            if self.editScreenState == .isForAddNew {
                locationMapController.isFromAddress = true
            }
            if self.editScreenState == .isFromCart {
                locationMapController.isFromCart = true
            }
            self.navigationController?.pushViewController(locationMapController, animated: true)
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextTf = self.view.viewWithTag(textField.tag+1) {
            nextTf.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
//        if textField == self.searchTextField {
//            self.searchString = ""
//            refreshData()
//            self.searchTextField.resignFirstResponder()
//
//        }else{
//            textField.text = ""
//        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var isEnableToChangeText = true
        var maxLenght = 0
        
        if textField == self.apartmentNumberTextField || textField == self.floorTextField {
            maxLenght = 15
        }else if textField == self.buildingTextField {
            maxLenght = 40
        }else if textField == self.streetTextField {
            maxLenght = 50
        }else {
            maxLenght = 100
            self.limitLabel.text = String(format: "%d/%d",textField.text!.count,maxLenght)
        }
        
        if (textField.text!.count >= maxLenght && range.length == 0){
            isEnableToChangeText = false // return NO to not change text
        }
        
        updateBorderAccordingToTextfield(textField)
        
     //   _ = validateLocationFields()
        return isEnableToChangeText
        
        
//        // check email validatoon
//        if textField == self.emailTextField {
//
//            var email = self.emailTextField.text
//            email = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
//            _ = validateEmail(email!)
//            return true
//
//        }else if textField == self.searchTextField{
//            return true
//        }else{
//
//            var isEnableToChangeText = true
//            var maxLenght = 0
//
//            if textField == self.apartmentNumberTextField || textField == self.floorTextField {
//                maxLenght = 15
//            }else if textField == self.buildingTextField {
//                maxLenght = 40
//            }else if textField == self.streetTextField {
//                maxLenght = 50
//            }else {
//                maxLenght = 100
//                self.limitLabel.text = String(format: "%d/%d",textField.text!.count,maxLenght)
//            }
//
//            if (textField.text!.count >= maxLenght && range.length == 0){
//                isEnableToChangeText = false // return NO to not change text
//            }
//
//            _ = validateLocationFields()
//            return isEnableToChangeText
//        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        defer{
            self.addtionaltextviewClearButton.isHidden = self.additionalDirectionTextView.text.count == 0
        }
        
        var isEnableToChangeText = true
        var maxLenght = 0
        maxLenght = 100
        self.limitLabel.text = String(format: "%d/%d",textView.text!.count,maxLenght)
        if (textView.text!.count >= maxLenght && range.length == 0){
            isEnableToChangeText = false // return NO to not change text
        }
        
        return isEnableToChangeText
    }
}

// MARK: GMSAutocompleteFetcherDelegate
extension EditLocationViewController: GMSAutocompleteFetcherDelegate {
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        
        self.predictionsArray.removeAll()
        self.predictionsArray = predictions
        self.refreshData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print("FailAutocompleteWithError:%@",error.localizedDescription)
    }
}

// MARK: DoneCancelNumberPadToolbarDelegate
extension EditLocationViewController: DoneCancelNumberPadToolbarDelegate {
    
    func doneCancelNumberPadToolbarDelegate(_ controller: DoneCancelNumberPadToolbar!, didClickDone textField: UITextField!) {
    }
    
    func doneCancelNumberPadToolbarDelegate(_ controller: DoneCancelNumberPadToolbar!, didClickCancel textField: UITextField!) {
    }
}

