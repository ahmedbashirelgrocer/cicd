//
//  StoreOutConverageAreaBottomSheetViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 04/06/2023.
//

import UIKit
import STPopup

class StoreOutConverageAreaBottomSheetViewController: UIViewController {
    @IBOutlet weak var imgPin: UIImageView!
    
    @IBOutlet weak var btnChangelocation: AWButton!
    
    @IBOutlet weak var lblLocationText: UILabel!
    
    class func showInBottomSheet( presentIn: UIViewController) {
        
        let addressView = StoreOutConverageAreaBottomSheetViewController.init(nibName: "StoreOutConverageAreaBottomSheetViewController", bundle: .resource)
        let popupController = STPopupController(rootViewController: addressView)
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
    
    

    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func changeLocationAction(_ sender: Any) {
        
    }
    @IBAction func cancelAction(_ sender: Any) {
      
        self.presentingViewController?.navigationController?.dismiss(animated: false)
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
