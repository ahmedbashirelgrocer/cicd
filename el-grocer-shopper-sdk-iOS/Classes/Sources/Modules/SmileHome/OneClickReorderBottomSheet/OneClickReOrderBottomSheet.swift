//
//  OneClickReOrderBottomSheet.swift
//  Adyen
//
//  Created by Abdul Saboor on 28/02/2024.
//

import UIKit

class OneClickReOrderBottomSheet: UIViewController {
    
    @IBOutlet var bottomSheetBGView: AWView! {
        didSet {
            bottomSheetBGView.roundTopWithTopShadow(radius: 12)
        }
    }
    @IBOutlet var imgGrocery: UIImageView!
    @IBOutlet var lblStoreName: UILabel! {
        didSet {
            lblStoreName.setH3SemiBoldStyle()
        }
    }
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var checkoutBGView: AWView! {
        didSet {
            checkoutBGView.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
            checkoutBGView.cornarRadius = 22
        }
    }
    @IBOutlet var itemNumBGView: AWView! {
        didSet {
            itemNumBGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            itemNumBGView.cornarRadius = 14
        }
    }
    @IBOutlet var lblItemNum: UILabel! {
        didSet {
            lblItemNum.setBody3RegDarkStyle()
            lblItemNum.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        }
    }
    @IBOutlet var imgArrowForward: UIImageView!
    @IBOutlet var lblCheckout: UILabel! {
        didSet {
            lblCheckout.text = localizedString("CHECKOUT", comment: "")
            lblCheckout.setBody3BoldUpperWhiteStyle()
        }
    }
    @IBOutlet var lblPrice: UILabel! {
        didSet {
            lblPrice.text = localizedString("AED 777.99", comment: "")
            lblPrice.setBody3BoldUpperWhiteStyle()
        }
    }
    
    var grocery: Grocery?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setGroceryData()
    }

    @IBAction func btnCrossHandler(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnCheckoutHandler(_ sender: Any) {
    }
    
    
    func setGroceryData() {
        let name = self.grocery?.name ?? ""
        self.lblStoreName.text = name
        
        if let imgUrl = URL(string: self.grocery?.smallImageUrl ?? "") {
            self.imgGrocery.sd_setImage(with: imgUrl)
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
