//
//  OneClickReOrderBottomSheet.swift
//  Adyen
//
//  Created by Abdul Saboor on 28/02/2024.
//

import UIKit

class OneClickReOrderBottomSheet: UIViewController {

    @IBOutlet var bottomSheetBGView: AWView!
    @IBOutlet var imgGrocery: UIImageView!
    @IBOutlet var lblStoreName: UILabel!
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var checkoutBGView: AWView!
    @IBOutlet var itemNumBGView: AWView!
    @IBOutlet var lblItemNum: UILabel!
    @IBOutlet var imgArrowForward: UIImageView!
    @IBOutlet var lblCheckout: UILabel!
    @IBOutlet var lblPrice: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func btnCrossHandler(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnCheckoutHandler(_ sender: Any) {
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
