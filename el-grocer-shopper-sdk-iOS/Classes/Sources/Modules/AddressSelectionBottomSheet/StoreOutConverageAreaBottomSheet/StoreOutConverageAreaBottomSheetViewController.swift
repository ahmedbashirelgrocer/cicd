//
//  StoreOutConverageAreaBottomSheetViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 04/06/2023.
//

import UIKit
import STPopup
import CoreLocation

class StoreOutConverageAreaBottomSheetViewController: UIViewController {
    @IBOutlet weak var imgPin: UIImageView! {
        didSet{
            if SDKManager.shared.isSmileSDK {
                imgPin.image = UIImage(name: "DeliveryAddressPin")
            }
        }
    }
    @IBOutlet weak var btnChangelocation: AWButton! {
        didSet{
            btnChangelocation.setBackgroundColor(ApplicationTheme.currentTheme.themeBasePrimaryColor, forState: UIControl.State())
        }
    }
    @IBOutlet weak var btnCancel: UIButton!{
        didSet{
            btnCancel.setTitleColor(ApplicationTheme.currentTheme.themeBasePrimaryColor, for: UIControl.State())
        }
    }
    
    @IBOutlet weak var lblLocationText: UILabel! {
        didSet{
            lblLocationText.setBody1RegDarkStyle()
        }
    }
    
    private var location : CLLocation?
    private var address : String?
    var crossCall : ((_ isChangeLocation: Bool) -> Void)?
    
    class func showInBottomSheet(location: CLLocation, address: String, presentIn: UIViewController, _ crossCall : ((_ isChangeLocation: Bool) -> Void)?) {
        
        let storeOutConveragView = StoreOutConverageAreaBottomSheetViewController.init(nibName: "StoreOutConverageAreaBottomSheetViewController", bundle: .resource)
        storeOutConveragView.configureWith(location, address: address)
        storeOutConveragView.crossCall = crossCall
        let popupController = STPopupController(rootViewController: storeOutConveragView)
        popupController.navigationBarHidden = true
        popupController.style = .bottomSheet
        popupController.backgroundView?.alpha = 1
        popupController.containerView.layer.cornerRadius = 16
        popupController.navigationBarHidden = true
        popupController.present(in: presentIn)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height:  333)
        landscapeContentSizeInPopup = CGSize(width: ScreenSize.SCREEN_HEIGHT , height: 333)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(_ location: CLLocation, address:String) {
        self.location = location
        self.address = address
    }
    

    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func changeLocationAction(_ sender: Any) {
        self.dismiss(animated: false) {
            if let clouser = self.crossCall {
                clouser(true)
            }
            Thread.OnMainThread {}
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: false) {
            if let clouser = self.crossCall {
                clouser(false)
            }
            Thread.OnMainThread {}
        }
       
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
