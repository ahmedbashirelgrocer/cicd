//
//  StorePageHeader.swift
//  Adyen
//
//  Created by saboor Khan on 02/05/2024.
//

import UIKit
import SDWebImage

class StorePageHeader: UIView {
    //bgview
    @IBOutlet weak var btnBack: UIButton!
    // chat help
    @IBOutlet weak var navBarChatButtonContainer: UIView!
    @IBOutlet weak var imgHelp: UIImageView!
    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var btnHelp: UIButton!
    //grocery
    @IBOutlet weak var groceryImageView: UIImageView!
    @IBOutlet weak var lblGroceryName: UILabel!
    @IBOutlet weak var lblGroceryNameTopAnchor: NSLayoutConstraint!
    //slot
    @IBOutlet weak var slotBGView: UIView!
    @IBOutlet weak var lblSlot: UILabel!
    @IBOutlet weak var imgSlotArrowDown: UIImageView!
    //search view
    @IBOutlet weak var searchBGView: AWView!
    @IBOutlet weak var lblSearchPlaceHolder: UILabel!
    @IBOutlet weak var imgSearch: UIImageView!
    //shopping list
    @IBOutlet weak var btnShoppingListBGView: AWView!
    @IBOutlet weak var imgBtnShoppingList: UIImageView!
    @IBOutlet weak var lblShoppingList: UILabel!
    
    @IBOutlet weak var searchBGViewTopWithSlot: NSLayoutConstraint!
    @IBOutlet weak var searchBGViewTopWithBGView: NSLayoutConstraint!
    @IBOutlet weak var searchBGViewleadingConstraint: NSLayoutConstraint!
    
    private let isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    var presenter: StorePageHeaderType! { // = StorePageHeaderPresenter()
        didSet {
            presenter.delegateOutputs = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpInitialAppearance()
        self.setUpTheme()
    }

    
    func setUpInitialAppearance() {
        //grocery
        self.lblGroceryName.textAlignment =  ElGrocerUtility.sharedInstance.isArabicSelected() ? .right : .left
        //search
        lblSearchPlaceHolder.text = localizedString("search_products", comment: "")
        searchBGView.borderWidth = 1.0
        searchBGView.cornarRadius = 22
        imgSearch.image = UIImage(name: "search-SearchBar")
        lblShoppingList.text = localizedString("Shopping_list_Titile", comment: "")
        btnShoppingListBGView.cornarRadius = 18
        imgBtnShoppingList.image = UIImage(name: "btnShoppingListSingleStore")
        //help
        lblHelp.text = localizedString("btn_help", comment: "")
        //arabic mode
        if ElGrocerUtility.sharedInstance.isArabicSelected() { // inject arabic mode value
            self.btnBack.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        self.searchBGViewTopWithBGView.constant = 52
    }
    
    func setUpTheme() {
        //grocery
        lblGroceryName.setHeadLine5MediumDarkStyle()
        //slot
        lblSlot.setBody3RegDarkStyle()
        //search
        lblSearchPlaceHolder.setBody3RegDarkGreyStyle()
        searchBGView.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
        //shopping list
        lblShoppingList.setCaptionOneSemiBoldDarkStyle()
        btnShoppingListBGView.backgroundColor = ApplicationTheme.currentTheme.buttonShoppingListBGColor
        //help
        lblHelp.setCaptionOneSemiBoldDarkStyle()
        imgHelp.changePngColorTo(color: ApplicationTheme.currentTheme.themeBasePrimaryBlackColor)
    }
    
    func AssignImage(imageUrl: String){
        if imageUrl.range(of: "http") != nil {
            
            self.groceryImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
                if error != nil {
                    self.groceryImageView.image = productPlaceholderPhoto
                }
                
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.groceryImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryImageView.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    

    @IBAction func btnSearchAction(_ sender: Any) {
        self.presenter.inputs?.searchBarTapped()
    }
    
    @IBAction func btnSelectSlotAction(_ sender: Any) {
        self.presenter.inputs?.slotButtonTpped()
    }
    
    @IBAction func btnShoppingListAction(_ sender: Any) {
        self.presenter.inputs?.shoppingListTpped()
    }
    @IBAction func btnBackAction(_ sender: Any) {
        self.presenter.inputs?.backButtonPressed()
    }
    
    @IBAction func btnHelpAction(_ sender: Any) {
        self.presenter.inputs?.helpButtonPressed()
    }
}


extension StorePageHeader: StorePageHeaderOutputs {
    func setGroceryTitle(grocery: String) {
        self.lblGroceryName.text = grocery
    }
    
    func setGroceryImage(url: String) { // Should be URL tpye
        self.AssignImage(imageUrl: url)
    }
    
    func setDeliverySlot(slot: String) {
        self.lblSlot.text = slot
    }
    
    func shouldHideSlot(isHidden: Bool) {
        self.lblGroceryNameTopAnchor.constant = isHidden ? 14 : 4
        self.slotBGView.visibility = isHidden ? .gone : .visible
        self.navBarChatButtonContainer.isHidden = isHidden
    }
    
    func scrollViewDidScroll(y: CGFloat) {
        print("searchBGViewTopWithSlot: \(self.searchBGViewTopWithSlot)")
        print("searchBGViewTopWithBGView: \(self.searchBGViewTopWithBGView)")
        
        if y > 10 {
            self.searchBGViewleadingConstraint.constant = 56
            self.searchBGViewTopWithBGView?.constant = y <= 52 ? (52 - y) : 0
            if y > 20 {
                self.imgHelp.visibility = .gone
                self.groceryImageView.visibility = .gone
                self.lblGroceryName.visibility = .gone
            }
        } else {
            self.searchBGViewleadingConstraint.constant = 16
            self.searchBGViewTopWithBGView.constant = 52
            if y < 20 {
                self.imgHelp.visibility = .visible
                self.groceryImageView.visibility = .visible
                self.lblGroceryName.visibility = .visible
            }
        }
    }

    
}
