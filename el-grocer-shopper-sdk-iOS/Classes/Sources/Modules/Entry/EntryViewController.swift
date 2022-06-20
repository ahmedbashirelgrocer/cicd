//
//  EntryViewController.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 27/01/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import AVKit
import AVFoundation
import RxSwift
import RxCocoa
//import FirebaseCrashlytics
// import RevealingSplashView

class EntryViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var lblAlreadyHaveMsg: UILabel! {
        didSet{
            lblAlreadyHaveMsg.text = localizedString("area_selection_already_have_an_account_label", comment: "")
            lblAlreadyHaveMsg.setH4BoldWhiteStyle()
        }
    }
    @IBOutlet var lblNewToElgrocer: UILabel!{
        didSet{
            lblNewToElgrocer.text = localizedString("lbl_new_to_elgrocer", comment: "")
            lblNewToElgrocer.setH4BoldWhiteStyle()
        }
    }
    
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var iconConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lableDetialToUser: UILabel!
    @IBOutlet weak var orLable: UILabel! {
        didSet{
            orLable.text = localizedString("lbl_or", comment: "")
        }
        
    }
    @IBOutlet weak var signUpButton: UIButton!

    // MARK: Properties
    var elGrocerNavigationController: ElGrocerNavigationController {
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        return navController
    }
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    
    // MARK: Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return self.isDarkMode ? UIStatusBarStyle.darkContent :  UIStatusBarStyle.lightContent
        } else {
            return .default
            // Fallback on earlier versions
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   self.playVideo()
        self.addBackButton()
        self.setupInitialControllerAppearance()
        NotificationCenter.default.addObserver(self,selector: #selector(EntryViewController.handleDeepLink), name: NSNotification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
    //  self.perform(#selector(self.showLocationCustomPopUp), with: nil, afterDelay: 2.0)
         self.isNeedToHideButtons(false)
         self.setButtonAlpha(1.0)
         self.navigationController?.setNavigationBarHidden(true, animated: false)
        //self.splashAnimation()
    }
    
//    func splashAnimation () {
//
//
//        let revealingSplashView = RevealingSplashView(iconImage: UIImage(name: "splash-icon")!,iconInitialSize: CGSize(width: 220, height: 80), backgroundColor: UIColor(red:0.11, green:0.56, blue:0.95, alpha:1.0))
//
//        //Adds the revealing splash view as a sub view
//        self.view.addSubview(revealingSplashView)
//
//        //Starts animation
//        revealingSplashView.startAnimation(){
//            print("Completed")
//        }
//
//
//    }
    
   
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        self.showViewWithAnimation()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
    }
    @objc
    func trackScreenName() {
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.DetectLocation.rawValue, screenClass: String(describing: self.classForCoder))
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KLocationChange), object: nil)
    }

    private func isNeedToHideButtons (_ isHide : Bool) {

        loginButton.isHidden = isHide
       // skipButton.isHidden = isHide
        signUpButton.isHidden = isHide

      //  signUpButton.enableWithAnimation(false)


    }

    private func setButtonAlpha(_ alphaValue : CGFloat) {
       // skipButton.alpha = alphaValue
        signUpButton.alpha = alphaValue
        loginButton.alpha = alphaValue
    }

    private func showViewWithAnimation () -> Void {
//  && self.bottomViewButtonsCenteralConstraint != nil
        guard self.iconConstraint != nil  else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
           // _ = self.bottomViewButtonsCenteralConstraint.constant = ScreenSize.SCREEN_WIDTH * 0.172
            if self.view.frame.size.height < 667 {
                _ = self.iconConstraint.setMultiplier(multiplier: 0.3)
            }else{
                _ = self.iconConstraint.setMultiplier(multiplier: 0.545)
            }
            UIView.animate(withDuration:1.5, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }) { (isCompleted) in
                self.lableDetialToUser.isHidden = false
            }
        }
        self.perform(#selector(self.trackScreenName), with: nil, afterDelay: 1)
    }
    
    @objc func showLocationCustomPopUp() {
        
        if CLLocationManager.locationServicesEnabled(){
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                  LocationManager.sharedInstance.requestLocationAuthorization()
                 NotificationCenter.default.addObserver(self, selector: #selector(self.locationUpdate(_:)), name:NSNotification.Name(rawValue: KLocationChange), object: nil)
            case .restricted , .denied:
                LocationManager.sharedInstance.requestLocationAuthorization()
                 self.goToStoreVC()
//                  let SDKManager = SDKManager.shared
//                  _ = LocationPopUp.showLocationPopUp(self, withView: SDKManager.window!)
            case .authorizedAlways, .authorizedWhenInUse:
                  print("Have Location services Access")
                  LocationManager.sharedInstance.requestLocationAuthorization()
                  LocationManager.sharedInstance.fetchCurrentLocation()
                  if LocationManager.sharedInstance.currentLocation.value != nil {
                    self.goToStoreVC()
                  }else{
                    NotificationCenter.default.addObserver(self, selector: #selector(self.locationUpdate(_:)), name:NSNotification.Name(rawValue: KLocationChange), object: nil)
                  }
            }
        }else{
            LocationManager.sharedInstance.requestLocationAuthorization()
            self.goToStoreVC()
        }

    }

    @objc func locationUpdate(_ notification: NSNotification?)  {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KLocationChange), object: nil);
        self.goToStoreVC()
    }
    
    fileprivate func goToStoreVC() {
        
       
        if let location = LocationManager.sharedInstance.currentLocation.value {
            
             self.gotToMapSelection(nil)
            
            
//
//            let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//            deliveryAddress.latitude = location.coordinate.latitude
//            deliveryAddress.longitude = location.coordinate.longitude
//            deliveryAddress.address = "Current Location"
//            self.fetchGroceries(deliveryAddress)
            /*
            
             let spinner = SpinnerView.showSpinnerViewInView(self.view)
            
            LocationManager.sharedInstance.getAddressForLocation(location, successHandler: { (address) in
                if(spinner != nil){
                    spinner?.removeFromSuperview()
                }
                
                if  address.lines?.count ?? 0 > 0 {
                    let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    deliveryAddress.latitude = location.coordinate.latitude
                    deliveryAddress.longitude = location.coordinate.longitude
                    deliveryAddress.address = address.lines?.joined(separator: ",") ?? ""
                     self.gotToMapSelection(deliveryAddress)
                }else{
                    let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    deliveryAddress.latitude = location.coordinate.latitude
                    deliveryAddress.longitude = location.coordinate.longitude
                    deliveryAddress.address = "Current Location"
                    self.gotToMapSelection(deliveryAddress)
                }
          
            }) { (error) in
                
                let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                deliveryAddress.latitude = location.coordinate.latitude
                deliveryAddress.longitude = location.coordinate.longitude
                deliveryAddress.address = "Current Location"
                self.gotToMapSelection(deliveryAddress)
            }
            
            */

        }else{
             self.gotToMapSelection(nil , false)
        }
    }
    
    private func gotToMapSelection(_ currentAddress: DeliveryAddress? , _ isLatLngOnly : Bool = true  ) {
        
        let locationMapController = ElGrocerViewControllers.locationMapViewController()
        locationMapController.delegate = self
        locationMapController.isConfirmAddress = false
        if let location = LocationManager.sharedInstance.currentLocation.value {
            locationMapController.locationCurrentCoordinates = location.coordinate
        }
        if isLatLngOnly == false {
             locationMapController.fetchDeliveryAddressFromEntry = currentAddress
        }
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [locationMapController]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false) {
            debugPrint("VC Presented")
        }
        
    }
  
    private func playVideo() {
        
        guard let videoURL = Bundle.resource.url(forResource: "Intro", withExtension: "mp4") else {
            debugPrint("Intro.mp4 not found")
            return
        }
        
        self.player = AVPlayer(url: videoURL)
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer!.frame = self.view!.bounds
        self.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.insertSublayer(playerLayer!, at: 0)
        self.player!.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(EntryViewController.playerItemDidReachEnd(_:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 16), queue: DispatchQueue.main, using: { ( currentTime) in
            
            var titleStr = ""
            
            let currentSecond : Float64 = CMTimeGetSeconds(currentTime)
            if(currentSecond > 0 && currentSecond < 4.0){
                self.bgView.isHidden = true
                titleStr = localizedString("save_money", comment: "")
            }else if(currentSecond > 4.0 && currentSecond < 8.0){
                titleStr = localizedString("save_time", comment: "")
            }else if(currentSecond > 8.0 && currentSecond < 12.0){
                titleStr = localizedString("stay_healthy", comment: "")
            }else {
                titleStr = localizedString("have_fun", comment: "")
            }
            
           // self.titleLabel.text = titleStr
        })
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        self.player!.seek(to: CMTime.zero)
        self.player!.play()
    }
    
    @objc func handleDeepLink() {
        
      if (ElGrocerUtility.sharedInstance.deepLinkURL.isEmpty == false){
        
        self.gotToMapSelection(nil)
            
//            let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
//            dashboardLocationVC.isFindStore = true
//            let navigationController = self.elGrocerNavigationController
//            navigationController.viewControllers = [dashboardLocationVC]
//            navigationController.setLogoHidden(true)
//            navigationController.modalPresentationStyle = .fullScreen
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else {return}
//            self.present(navigationController, animated: true, completion: nil)
//        }
            
        }
    }
    
    // MARK: Actions
    
    @IBAction func findStoreHandler(_ sender: Any) {
        
        /*let orderTrackingVC = ElGrocerViewControllers.orderTrackingViewController()
         let navigationController = self.elGrocerNavigationController
         navigationController.viewControllers = [orderTrackingVC]
         navigationController.setLogoHidden(true)
         present(navigationController, animated: true, completion: nil)*/
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("choose_find_store_nearby")
        guard UserDefaults.didUserSetAddress() == true else {
            let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
            dashboardLocationVC.isFindStore = true
            let navigationController = self.elGrocerNavigationController
            navigationController.viewControllers = [dashboardLocationVC]
            navigationController.setLogoHidden(true)
            navigationController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.present(navigationController, animated: true, completion: nil)
            }
            return
        }
        
        (SDKManager.shared).showAppWithMenu()
    }
    
    override func backButtonClick() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Methods
    
    /** Sets up the initial appearance of the controller */
    func setupInitialControllerAppearance() {
        
        self.setupButtonsAppearance()
        self.setupLabelsAppearance()
    }

    /** Sets the initial appearance of all buttons */
    private func setupButtonsAppearance() {
        
//        skipButton.titleLabel?.font = UIFont.SFUIRegularFont(16.0)
//        skipButton.setTitleColor(UIColor.white, for: UIControl.State())
//        skipButton.setTitle(localizedString("entry_skip_button_title", comment: ""), for: UIControl.State())

//        "entry_detect_my_location_button_title" = "DETECT MY LOCATION";
//        "entry_maually_select_location_button_title" = "MANUALLY SELECT LOCATION";
        
        
        lblNewToElgrocer.text = localizedString("lbl_new_to_elgrocer", comment: "")
        
        loginButton.layer.backgroundColor = UIColor.navigationBarColor().cgColor
        loginButton.setButton2SemiBoldWhiteStyle()
        loginButton.setTitle("  " + localizedString("entry_detect_my_location_button_title", comment: ""), for: UIControl.State())
        
        
        signUpButton.layer.borderColor = UIColor.navigationBarColor().cgColor
        signUpButton.setH4SemiBoldGreenStyle()
        signUpButton.setTitle(localizedString("area_selection_login_button_title", comment: ""), for: UIControl.State())


     


//        privacyButton.titleLabel?.font = UIFont.SFUIRegularFont(12.0)
//        privacyButton.setTitleColor(UIColor.white, for: UIControl.State())
//        privacyButton.setTitle(localizedString("area_selection_Privacy_Policy_button_title", comment: ""), for: UIControl.State())
        
        lableDetialToUser.setBody2RegWhiteStyle()
        lableDetialToUser.text = localizedString("user_detail_about_location_entryScreen", comment: "")

    }
    
    private func setupLabelsAppearance() {

        self.orLable.setBody2BoldWhiteStyle()
        self.orLable.text = localizedString("area_selection_OR_Lable", comment: "")
        
        // logo Tag Label appearance
//        self.logoTagLabel.textColor = UIColor.white
//        self.logoTagLabel.font = UIFont.SFUIRegularFont(14.0)
//        self.logoTagLabel.text = localizedString("groceries_to_your_door", comment: "")
        
        // title Label appearance
//        self.titleLabel.textColor = UIColor.white
//        self.titleLabel.font = UIFont.SFUIRegularFont(32.0)
//        self.titleLabel.text = localizedString("save_money", comment: "")
        
        
        // logIn Or SignUp Label appearance
        
        //Step 1: Define a normal attributed string for non-link texts
        let titleStr = String(format: "%@ %@ %@ %@",localizedString("click_here_to", comment: ""),localizedString("entry_login_button_title", comment: ""),localizedString("or_label_text", comment: ""),localizedString("register_title", comment: ""))
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(16.0)]
        
      //  self.logInOrSignUpLabel.attributedText = NSAttributedString(string: titleStr, attributes: attributes)
        
        //Step 2: Define a selection handler block
        
        let labelHandler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            
            if substring == localizedString("register_title", comment: "") {
                
                print("SignUp Tapped")
                let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
                let navController = self.elGrocerNavigationController
                navController.viewControllers = [registrationProfileController]
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            }else{
                
                print("Login Tapped")
                let signInController = ElGrocerViewControllers.signInViewController()
                let navController = self.elGrocerNavigationController
                navController.viewControllers = [signInController]
                navController.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.present(navController, animated: true, completion: nil)
                    
                }
            }
        }
        
        //Step 3: Add link substrings
    //    self.logInOrSignUpLabel.setLinksForSubstrings([localizedString("entry_login_button_title", comment: ""), localizedString("register_title", comment: "")], withLinkHandler: labelHandler)
    }

    @IBAction func signUp(_ sender: UIButton) {
    
        print("\(sender.titleLabel?.text ?? "signup action") Tapped")
      //  ElGrocerEventsLogger.sharedInstance.trackDetectManuallySelectLocationClicked()
       // self.findStoreHandler(self.skipButton as Any)
        
//        print("SignUp Tapped")
//        let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
//        let navController = self.elGrocerNavigationController
//        navController.viewControllers = [registrationProfileController]
//        self.present(navController, animated: true, completion: nil)
//
        
        let signInController = ElGrocerViewControllers.signInViewController()
        signInController.dismissMode = .dismissModal
        signInController.isCommingFrom = .entry
        let navController = self.elGrocerNavigationController
        navController.viewControllers = [signInController]
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
      //  self.navigationController?.pushViewController(signInController, animated: true)
        
        
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        self.showLocationCustomPopUp();
      //  ElGrocerEventsLogger.sharedInstance.trackDetectMyLocationClicked()
        // FireBaseEventsLogger.trackDetectMyLocationClicked()

    }

    
    @IBAction func termAndPolicyAction(_ sender: Any) {


        let webVC = ElGrocerViewControllers.privacyPolicyViewController()
        webVC.isTermsAndConditions = false
        let nav : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: webVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
       // self.navigationController?.pushViewController(webVC, animated: true)

    }
    
    
}

extension EntryViewController: LocationMapViewControllerDelegate {
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //Hunain 26Dec16
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
        //Do nothing
        //Hunain 26Dec16
        guard let location = location, let name = name else {return}
        addDeliveryAddressForAnonymousUser(withLocation: location, locationName: name,buildingName: building!) { (deliveryAddress) in
            (SDKManager.shared).showAppWithMenu()
        }
    }
    
    /** Since the user is anonymous, we cannot send the delivery address on the backend.
     We need to store the delivery address locally and continue as an anonymous user */
    private func addDeliveryAddressForAnonymousUser(withLocation location: CLLocation, locationName: String,buildingName: String,completionHandler: (_ deliveryAddress: DeliveryAddress) -> Void) {
        
        // Remove any previous area
        //DeliveryAddress.clearEntity()
        DeliveryAddress.clearDeliveryAddressEntity()
        
        // Insert new area
        //let deliveryAddress = DeliveryAddress.createObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        deliveryAddress.locationName = locationName
        deliveryAddress.latitude = location.coordinate.latitude
        deliveryAddress.longitude = location.coordinate.longitude
        deliveryAddress.address = locationName
        deliveryAddress.apartment = ""
        deliveryAddress.building = buildingName
        deliveryAddress.street = ""
        deliveryAddress.floor = ""
        deliveryAddress.houseNumber = ""
        deliveryAddress.additionalDirection = ""
        deliveryAddress.isActive = NSNumber(value: true)
        DatabaseHelper.sharedInstance.saveDatabase()
        UserDefaults.setDidUserSetAddress(true)
        completionHandler(deliveryAddress)
        
    }
    
}

extension EntryViewController:LocationPopUpProtocol {
    
    func enableLocationServices(){
        
        
        // Initialize and Authorize location manager
        LocationManager.sharedInstance.requestLocationAuthorization()
    }
}
