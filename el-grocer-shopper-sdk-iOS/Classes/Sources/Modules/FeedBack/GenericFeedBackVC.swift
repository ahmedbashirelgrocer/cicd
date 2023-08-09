//
//  GenericFeedBackVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 21/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import FloatRatingView
//import PageControl
import SDWebImage
import IQKeyboardManagerSwift

enum feedBackType {
    case clickAndCollectFeedBack
    case deliveryFeedBack
}
struct selectedOption{
    var optionA = 0
    var optionB = 0
    var optionC = 0
    var optionD = 0
}
struct selectedRating{
    var speed : Float = 0
    var quality : Float = 0
    var accuracy : Float = 0
}
var delivery : Float = 0
var speed = selectedOption()
var quality = selectedOption()
var price = selectedOption()

var ratingState = selectedRating()
var commentFeedBack : String = ""

class GenericFeedBackVC: UIViewController {

    @IBOutlet var storeInfoBGView: UIView!
    @IBOutlet var lblStoreName: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var storeImage: UIImageView!
    @IBOutlet var genericStarRatingView: AWView!
    @IBOutlet var genericCollectionView: UICollectionView!
    @IBOutlet var feedBackPageControl: UIPageControl! {
        didSet {
            feedBackPageControl.currentPageIndicatorTintColor = ApplicationTheme.currentTheme.pageControlActiveColor
        }
    }

    var feedBackType : feedBackType = .deliveryFeedBack
    var orderTracking:OrderTracking!
    var feedBackDone = false
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    // MARK: Lifecycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialAppearence()
        setFonts()
        setCollectionViewDelegates()
        setViewData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarAppeaence()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if feedBackDone{
            
        }else{
            submitFeedback(backButton : true)
            resetValues()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetValues()
    }
    func resetValues(){
        delivery = 0
        speed = selectedOption()
        quality = selectedOption()
        price = selectedOption()

        ratingState = selectedRating()
        commentFeedBack = ""
    }
    func setCollectionViewDelegates() {
        self.genericCollectionView.register(UINib.init(nibName: "GenericFeedBackCollectionCell", bundle: Bundle.resource), forCellWithReuseIdentifier: "GenericFeedBackCollectionCell")
        genericCollectionView.delegate = self
        genericCollectionView.dataSource = self
    }
    private func setViewData(){
        
        
        /* ------ Here we are setting grocery image ------ */
        if self.orderTracking.imageUrl != nil && self.orderTracking.imageUrl?.range(of: "http") != nil {
            
            self.storeImage.sd_setImage(with: URL(string: self.orderTracking.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.storeImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.storeImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
        
        self.lblStoreName.text = self.orderTracking.retailerName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, LLLL dd, hh:mm a"
        
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if phoneLanguage == "ar" {
            dateFormatter.locale = Locale(identifier: "ar")
        }
        
        let dateStr = dateFormatter.string(from: self.orderTracking.orderCreatedDate)
        
        self.lblTime.text = dateStr
    }
    
    //MARK: Appearence
    func setNavigationBarAppeaence(){
         self.navigationItem.setHidesBackButton(true, animated: false)
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        addBackButtonWithCrossIconLeftSide(sdkManager.isShopperApp ? .white : .newBlackColor())
    }
    
    override func crossButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setInitialAppearence(){
        
        self.storeImage.layer.cornerRadius = storeImage.layer.frame.height / 2
        
        if feedBackType == .clickAndCollectFeedBack{
            self.title = localizedString("lbl_feedback_clickAndCollect_title", comment: "")
            self.feedBackPageControl.numberOfPages = 4
            self.feedBackPageControl.isUserInteractionEnabled = false
            self.feedBackPageControl.currentPage = 1
        }else{
            self.title = localizedString("lbl_feedback_delivery_title", comment: "")
            self.feedBackPageControl.numberOfPages = 5
            self.feedBackPageControl.isUserInteractionEnabled = false
            self.feedBackPageControl.currentPage = 1
        }
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
    }
    func setFonts(){
        
        self.lblStoreName.setH3SemiBoldDarkStyle()
        self.lblTime.setCaptionOneRegDarkStyle()
    }
    @objc func submitFeedback(backButton : Bool = false){
        if feedBackType == .clickAndCollectFeedBack{
            let quality = ElGrocerUtility.sharedInstance.isArabicSelected() ? Int( ratingState.accuracy) : Int(ratingState.accuracy)
            let speed = ElGrocerUtility.sharedInstance.isArabicSelected() ? Int( ratingState.speed) : Int(ratingState.speed)
            let accuracy = ElGrocerUtility.sharedInstance.isArabicSelected() ? Int( ratingState.quality) :  Int(ratingState.quality)
            
            feedbacApiCall(speed: "\(speed)", delivery: quality, price: "", accuracy: "\(accuracy)", Comment: commentFeedBack , backButton: backButton)
        }else{
            var qualityVal = 0
            var priceVal = 0
            var speedVal = 0
            
            //delivery
            let deliveryVal = ElGrocerUtility.sharedInstance.isArabicSelected() ? Int(delivery) :  Int(delivery)
            //speed
            if speed.optionA == 1{
                speedVal =  1
            }else if speed.optionB == 1{
                speedVal =  2
            }else if speed.optionC == 1{
                speedVal =  3
            }else if speed.optionD == 1{
                speedVal =  4
            }else{
                speedVal = 0
            }
            //quality
            if quality.optionA == 1{
                qualityVal = 4
            }else if quality.optionB == 1{
                qualityVal =  3
            }else if quality.optionC == 1{
                qualityVal =  2
            }else if quality.optionD == 1{
                qualityVal =  1
            }else{
                qualityVal = 0
            }
            //price
            if price.optionA == 1{
                priceVal =  1
            }else if price.optionB == 1{
                priceVal =  2
            }else if price.optionC == 1{
                priceVal =  3
            }else if price.optionD == 1{
                priceVal = 0
            }else{
                priceVal = 0
            }
            feedbacApiCall(speed: "\(speedVal)", delivery: deliveryVal, price: "\(priceVal)", accuracy: "\(qualityVal)", Comment: commentFeedBack , backButton: backButton)
        }
    }
    
    func feedbacApiCall(speed : String , delivery : Int , price : String , accuracy : String , Comment : String , backButton : Bool){
        
       elDebugPrint("Submit Feedback")
        self.feedBackDone = true
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        let orderId = orderTracking.orderId.stringValue
        ElGrocerApi.sharedInstance.submitDeliveryFeedback(orderId,delivery: delivery, speed: speed, accuracy: accuracy, price: price, comments: Comment, completionHandler: ({ (result) -> Void in
            
            spinner?.removeFromSuperview()
            
            switch result {
            case .success(_):
               elDebugPrint("Submit Feedback Success")
                if backButton{
                   elDebugPrint("Submit Feedback Success")
                }else{
                    let reviewPopup = ReviewPopUp.createReviewPopUp()
                    reviewPopup.showPopUp()
                    reviewPopup.onDoneBlock = { result in
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                
            case .failure(let error):
               elDebugPrint(error)
            }
        }))
    }

}

extension GenericFeedBackVC: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if feedBackType == .clickAndCollectFeedBack{
            return 4
        }else{
            return 5
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        if feedBackType == .clickAndCollectFeedBack{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenericFeedBackCollectionCell", for: indexPath) as! GenericFeedBackCollectionCell
            cell.tag = 1
            cell.backGroundView.tag = indexPath.item
            cell.btnSubmit.addTarget(self, action: #selector(self.submitFeedback), for: .touchDown)
            cell.setInitialView(collectionView: collectionView, feedBackType: feedBackType, index: indexPath.item)
            cell.updateConstraints()
            cell.layoutSubviews()
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenericFeedBackCollectionCell", for: indexPath) as! GenericFeedBackCollectionCell
            cell.tag  = 2
            cell.backGroundView.tag = indexPath.item
            cell.btnSubmit.addTarget(self, action: #selector(self.submitFeedback), for: .touchDown)
            cell.setInitialView(collectionView: collectionView, feedBackType: feedBackType, index: indexPath.item)
            cell.layoutSubviews()
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let height = getHeight(Type: feedBackType, index: indexPath.item)
        //let topBottomPadding : CGFloat = 32.0
        return CGSize(width: collectionView.layer.bounds.width, height: collectionView.layer.bounds.height)
        //return CGSize(width: collectionView.layer.bounds.width, height: height + topBottomPadding)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.feedBackPageControl.currentPage = indexPath.item
    }
}

