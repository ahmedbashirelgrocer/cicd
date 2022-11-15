//
//  ListSearchBar.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 18/02/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import AnimatedGradientView
protocol ListSearchBarDelegate : class {
    func textViewDidChange()
    func searchBarButtonClicked(text : String?)
}
class ListSearchBar: UIView {

    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var contentView: AWView!
    @IBOutlet weak var searchProductListingTextView: UITextView!
    @IBOutlet var gredientV: AnimatedGradientView!
    
    weak var delegate:ListSearchBarDelegate?
    var gradientLayer = CAGradientLayer()
    var initailHeight  = 0
    var initialWidth =  0
    var initialY =  0
    var previousRect = CGRect.zero
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func addGredient() {
       
        gredientV.colors = [[UIColor.navigationBarColor(), UIColor.navigationBarWhiteColor()]]
        gredientV.type = .axial
      //  gredientV.direction = .custom
       
    }

    override func awakeFromNib() {

         self.backgroundColor = UIColor.navigationBarColor()
         self.addGredient()
         self.searchProductListingTextView.delegate = self
            self.searchProductListingTextView.textColor = UIColor.lightTextGrayColor()
            self.searchProductListingTextView.text = localizedString("shopping_PlaceHolder_Search_List", comment: "")
            self.searchButton.setTitle(localizedString("my_account_shop_now_button", comment: ""), for: .normal)
            self.adjustUITextViewHeight(self.searchProductListingTextView , isNewLine: false)
            self.searchButton.layer.cornerRadius = 3
            if  let lastSearchString = UserDefaults.getLastSearchList() {
                if !lastSearchString.isEmpty &&   lastSearchString != localizedString("shopping_PlaceHolder_Search_List", comment: "") {
                    self.searchProductListingTextView.text = lastSearchString
                    self.setUIColor(self.searchProductListingTextView)
                    self.crossButton.isHidden = false
                }
            }
    }
    func adjustUITextViewHeight(_ arg : UITextView , isNewLine : Bool )
    {

        arg.translatesAutoresizingMaskIntoConstraints = true
        let numLines = (arg.contentSize.height / arg.font!.lineHeight)
        guard numLines < 6.0 else {
              arg.isScrollEnabled = true
            return
        }
        arg.isScrollEnabled = false
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if initailHeight == 0 {
           initailHeight =  Int(arg.frame.size.height)
            initialWidth =  Int(ScreenSize.SCREEN_WIDTH - 60)
            initialY     =  0
            if phoneLanguage == "ar" {
              //  initialWidth = initialWidth - 55
            }
        }
        arg.sizeToFit()
        arg.frame.size.width = CGFloat(initialWidth)
        arg.frame.origin.y = CGFloat(initialY)
        if phoneLanguage == "ar" {
            arg.frame.origin.x = 40
        }else{
            arg.frame.origin.x = 5
        }
        if isNewLine {
            arg.frame.size.height = arg.frame.size.height + arg.font!.lineHeight
        }else{
           // arg.frame.size.height = CGFloat(height)
        }
        if Int(arg.frame.size.height) < initailHeight || numLines < 5 {
            arg.frame.size.height = CGFloat(initailHeight)
        }
        
        //arg.frame.size.height = arg.frame.size.height + 20 

        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.layoutIfNeeded()
        arg.setNeedsLayout()
        self.addGredient()
        

    }
//    func createGradientLayer() {
//        gradientLayer.removeFromSuperlayer()
//        gradientLayer.frame = self.bounds
//        gradientLayer.colors = [UIColor.colorWithHexString(hexString: "e5f1e3").cgColor, UIColor.white.cgColor]
//        gradientLayer.locations = [0, 0.5]
//
//        self.layer.insertSublayer(gradientLayer, at: 0)
//        // self.bringSubview(toFront: contentView)
//    }

    @IBAction func searchClicked(_ sender: Any) {

         guard !self.searchProductListingTextView.text.trimmingCharacters(in: .whitespaces).isEmpty && self.searchProductListingTextView.text.count > 0 && self.searchProductListingTextView.text != localizedString("shopping_PlaceHolder_Search_List", comment: "")  else {
            self.searchProductListingTextView.resignFirstResponder()
            return
        }
        if self.delegate != nil {
            FireBaseEventsLogger.trackMultiSearch(self.searchProductListingTextView.text ?? "")
            self.delegate?.searchBarButtonClicked(text: self.searchProductListingTextView.text)
            UserDefaults.setLastSearchList(self.searchProductListingTextView.text)
            GoogleAnalyticsHelper.trackMultiSearchShopClick()
            
        }
    }
    @IBAction func crossClicked(_ sender: Any) {

        self.crossButton.isHidden = true;
        self.searchProductListingTextView.text = nil
       // self.reloadHeader()
        self.setUIColor(self.searchProductListingTextView)
        self.searchProductListingTextView.text = localizedString("shopping_PlaceHolder_Search_List", comment: "")
        self.adjustUITextViewHeight(self.searchProductListingTextView , isNewLine: false)
        self.searchProductListingTextView.textColor = UIColor.lightTextGrayColor()
        self.setCursorToStartOfTextView(self.searchProductListingTextView)
    }

    func setCursorToStartOfTextView(_ textView : UITextView) -> Void {
        let newPosition = textView.beginningOfDocument
        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
    }

    func reloadHeader()  {
        if self.delegate != nil {
            self.delegate?.textViewDidChange()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.setNeedsDisplay()
                self.layoutIfNeeded()
            }
        }
    }

}
extension ListSearchBar : UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {

          textView.tintColor = UIColor.darkGrayTextColor()

        if textView.text == localizedString("shopping_PlaceHolder_Search_List", comment: "") {
            textView.text = nil
            textView.textColor = UIColor.colorWithHexString(hexString: "787878")
            self.setUIColor(textView)
        }

    }

    func textViewDidEndEditing(_ textView: UITextView) {

        self.setUIColor(textView)
        
        if textView.text.isEmpty {
            textView.text = localizedString("shopping_PlaceHolder_Search_List", comment: "")
            textView.textColor = UIColor.lightTextGrayColor()
        }
       self.adjustUITextViewHeight(self.searchProductListingTextView , isNewLine: false)
       self.reloadHeader()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == localizedString("shopping_PlaceHolder_Search_List", comment: "") {
            textView.text = nil
            textView.textColor = UIColor.colorWithHexString(hexString: "787878")
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {

        let pos = textView.endOfDocument
        let currentRect = textView.caretRect(for: pos)
        self.previousRect = self.previousRect.origin.y == 0.0 ? currentRect : previousRect
        if(currentRect.origin.y > previousRect.origin.y){
            //new line reached, write your code
           elDebugPrint("Started New Line")
          self.adjustUITextViewHeight(self.searchProductListingTextView , isNewLine: true)
        }else{
        self.adjustUITextViewHeight(self.searchProductListingTextView , isNewLine: false)
        self.crossButton.isHidden =     self.searchProductListingTextView.text.count == 0
        }
        self.setUIColor(textView)
        self.reloadHeader()
    }

    func setUIColor (_ textView : UITextView) {


        if !textView.text.trimmingCharacters(in: .whitespaces).isEmpty && textView.text.count > 0 &&  (textView.text != localizedString("shopping_PlaceHolder_Search_List", comment: "")){
           // self.searchButton.setImage(UIImage(name: "icSearchGreen"), for: .normal)

            self.searchButton.setTitle(localizedString("my_account_shop_now_button", comment: ""), for: .normal)
            self.searchButton.setBackgroundColor(UIColor.navigationBarColor(), forState: .normal)
         //   self.searchButton.setTitleColor(UIColor.lightGrayBGColor(), for: .normal)
        }else{
           // self.searchButton.setImage(UIImage(name: "icSearch"), for: .normal)
            self.searchButton.setTitle(localizedString("my_account_shop_now_button", comment: ""), for: .normal)
           self.searchButton.setBackgroundColor(UIColor.lightGray, forState: .normal)
          //  self.searchButton.setTitleColor(UIColor.lightGrayBGColor(), for: .normal)
        }
        
    }

}
