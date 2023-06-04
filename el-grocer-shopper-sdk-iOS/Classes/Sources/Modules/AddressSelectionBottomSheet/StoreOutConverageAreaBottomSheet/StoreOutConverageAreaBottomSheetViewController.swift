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
    @IBOutlet weak var imgPin: UIImageView!
    @IBOutlet weak var btnChangelocation: AWButton!
    @IBOutlet weak var lblLocationText: UILabel!
    
    private var location : CLLocation?
    private var address : String?
    var crossCall : (() -> Void)?
    
    class func showInBottomSheet(location: CLLocation, address: String, presentIn: UIViewController) {
        
        let storeOutConveragView = StoreOutConverageAreaBottomSheetViewController.init(nibName: "StoreOutConverageAreaBottomSheetViewController", bundle: .resource)
        storeOutConveragView.configureWith(location, address: address)
        storeOutConveragView.crossCall = {
            presentIn.presentedViewController?.navigationController?.dismiss(animated: true)
            presentIn.dismiss(animated: true)
        }
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
                clouser()
            }
            Thread.OnMainThread {
                ElGrocerUtility.sharedInstance.activeGrocery = nil
                ElGrocerUtility.sharedInstance.resetRecipeView()
                let profile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let locationDetails = LocationDetails.init(location: self.location,editLocation: nil, name: profile?.name ?? "" , address: self.address, building: "", cityName: "")
                let editLocationController = EditLocationSignupViewController(locationDetails: locationDetails, UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext), FlowOrientation.basketNav)
                UIApplication.topViewController()?.navigationController?.pushViewController(editLocationController, animated: true)
            }
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
        
        if let clouser = self.crossCall {
            clouser()
        }
        crossAction("")
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
