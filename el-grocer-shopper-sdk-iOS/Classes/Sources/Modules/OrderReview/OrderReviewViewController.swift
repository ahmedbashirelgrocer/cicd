//
//  OrderReviewViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 2/11/18.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage
//import PageControl


let kRatingViewId: Int  = 1
let kFirstQuestionId: Int  = 2
let kSecodQuestionId: Int  = 3
let kThirdQuestionId: Int  = 4

class FeedbackQuestion {
    
    var questionId: Int
    var questionTitle: String
    var answerTitle1: String?
    var answerTitle2: String?
    var answerTitle3: String?
    var answerTitle4: String?
    var isAdditionalInfoView: Bool = false
    
    init(_ id: Int, quesTitle: String, ansTitle1: String?, ansTitle2: String?, ansTitle3: String?, ansTitle4: String?, isInfoView: Bool) {
        
        self.questionId = id
        self.questionTitle = quesTitle
        self.answerTitle1 = ansTitle1
        self.answerTitle2 = ansTitle2
        self.answerTitle3 = ansTitle3
        self.answerTitle4 = ansTitle4
        self.isAdditionalInfoView = isInfoView
    }
}


class OrderReviewViewController: UIViewController {
    
    var orderTracking:OrderTracking!
    
    var data: [FeedbackQuestion] = []
    var pageController: PageControlViewController!
    var dataController: [UIViewController] = []
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    var delivery = 0
    var speed = 0
    var accuracy = 0
    var price = 0
    var comments = ""
    
    //MARK: Outlets
    @IBOutlet var groceryImage: UIImageView!
    
    @IBOutlet weak var groceryNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
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
        
        self.title = localizedString("delivery_feedback_title", comment: "")
        addBackButtonWithCrossIcon()
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OrderReviewViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        self.setViewData()
        
        self.data = [FeedbackQuestion.init(kRatingViewId, quesTitle: localizedString("how_was_your_delivery_title", comment: ""), ansTitle1: nil, ansTitle2: nil, ansTitle3: nil, ansTitle4: nil, isInfoView: false),
        FeedbackQuestion.init(kFirstQuestionId, quesTitle: localizedString("feedback_question1_title", comment: ""), ansTitle1: localizedString("feedback_question1_answer1", comment: ""), ansTitle2: localizedString("feedback_question1_answer2", comment: ""), ansTitle3: localizedString("feedback_question1_answer3", comment: ""), ansTitle4: localizedString("feedback_question1_answer4", comment: ""), isInfoView: false),
        FeedbackQuestion.init(kSecodQuestionId, quesTitle: localizedString("feedback_question2_title", comment: ""), ansTitle1: localizedString("feedback_question2_answer1", comment: ""), ansTitle2: localizedString("feedback_question2_answer2", comment: ""), ansTitle3: localizedString("feedback_question2_answer3", comment: ""), ansTitle4: localizedString("feedback_question2_answer4", comment: ""), isInfoView: false),
        FeedbackQuestion.init(kThirdQuestionId, quesTitle: localizedString("feedback_question3_title", comment: ""), ansTitle1: localizedString("feedback_question3_answer1", comment: ""), ansTitle2: localizedString("feedback_question3_answer2", comment: ""), ansTitle3: localizedString("feedback_question3_answer3", comment: ""), ansTitle4: nil, isInfoView: false),
        FeedbackQuestion.init(5, quesTitle: localizedString("feedback_question3_title", comment: ""), ansTitle1: nil, ansTitle2: nil, ansTitle3: nil, ansTitle4: nil, isInfoView: true)]
        
        for feedbackQuestion in self.data {
            
            print("Question Title:%@",feedbackQuestion.questionTitle)
            let reviewQuestion = ReviewQuestionViewController()
            reviewQuestion.feedbackQuestion = feedbackQuestion
            reviewQuestion.delegate = self
            self.dataController.append(reviewQuestion)
        }
        
        self.pageControl.numberOfPages = self.data.count
        self.pageControl.currentPage = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackgroundColorForBar(UIColor.clear)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PageControlViewController {
            self.pageController = controller
            self.pageController.delegate = self
            self.pageController.dataSource = self
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func setViewData(){
        
        self.groceryImage.layer.cornerRadius = 15
        self.groceryImage.layer.masksToBounds = true
        
        /* ------ Here we are setting grocery image ------ */
        if self.orderTracking.imageUrl != nil && self.orderTracking.imageUrl?.range(of: "http") != nil {
            
            self.groceryImage.sd_setImage(with: URL(string: self.orderTracking.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.groceryImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
        
        self.groceryNameLabel.text = self.orderTracking.retailerName
        self.groceryNameLabel.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.groceryNameLabel.textColor = UIColor.white
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, LLLL dd, hh:mm a"
        
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if phoneLanguage == "ar" {
            dateFormatter.locale = Locale(identifier: "ar")
        }
        
        let dateStr = dateFormatter.string(from: self.orderTracking.orderCreatedDate)
        
        self.timeLabel.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        self.timeLabel.text = dateStr
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.sendFeedbackToServer()
          self.dismiss(animated: true, completion: nil)
    }
}

extension OrderReviewViewController: ReviewQuestionDelegate {
    
    func ratingHandler(_ deliveryRating: Int){
        
        FireBaseEventsLogger.trackReviewEvents(screenName: "accurate", eventName: "EG_AddRating", params: ["Rating" : "\(deliveryRating)" , "OrderId" : self.orderTracking.orderId.stringValue])
        ElGrocerUtility.sharedInstance.deliveryRating = deliveryRating
        self.delivery = deliveryRating
        self.pageController.nextPage()
       
    }
    
    func answer1Handler(_ feedbackQuestion: FeedbackQuestion){
        
       // FireBaseEventsLogger.trackReviewEvents(screenName: "speed", eventName: "EG_AddRating", params: ["Title" : feedbackQuestion.questionTitle , "Rating" : "\(self.speed)", "OrderId" : self.orderTracking.orderId.stringValue])
        //Speed --- Early = 1, Accuracy --- Satisfied = 4, Price --- Cheaper = 1
        self.pageController.nextPage()
        
        switch feedbackQuestion.questionId {
            
        case kFirstQuestionId:
            self.speed = 1
            break
            
        case kSecodQuestionId:
            self.accuracy = 4
            break
            
        case kThirdQuestionId:
            self.price = 1
            break
            
        default:
            break
        }
        
        var rating = "0"
        var screenName = ""
        
        if feedbackQuestion.questionId == 2 {
            rating =  "\(self.speed)"
            screenName = "Speed"
        }else   if feedbackQuestion.questionId == 3 {
            rating =  "\(self.accuracy)"
             screenName = "Quality"
        }else   if feedbackQuestion.questionId == 4 {
            rating =  "\(self.price)"
            screenName = "price"
        }
        
        FireBaseEventsLogger.trackReviewEvents(screenName: screenName, eventName: "EG_AddRating" , params: ["Title" : feedbackQuestion.questionTitle , "Rating" : rating , "OrderId" : self.orderTracking.orderId.stringValue])
        
//        var rating = "0"
//
//        if feedbackQuestion.questionId == 2 {
//            rating =  "\(self.speed)"
//        }else   if feedbackQuestion.questionId == 3 {
//            rating =  "\(self.accuracy)"
//        }else   if feedbackQuestion.questionId == 4 {
//            rating =  "\(self.price)"
//        }
//
//
//
//        FireBaseEventsLogger.trackReviewEvents(screenName: "Speed", eventName: "EG_Rating", params: ["Title" : feedbackQuestion.questionTitle , "Rating" : rating, "OrderId" : self.orderTracking.orderId.stringValue])
    }
    
    func answer2Handler(_ feedbackQuestion: FeedbackQuestion){
        
        
        
        //Speed --- On Time = 2, Accuracy --- Somewhat satisfied = 3, Price --- About the same = 2
        self.pageController.nextPage()
        
        switch feedbackQuestion.questionId {
            
        case kFirstQuestionId:
            self.speed = 2
            break
            
        case kSecodQuestionId:
            self.accuracy = 3
            break
            
        case kThirdQuestionId:
            self.price = 2
            break
            
        default:
            break
        }
        
        var rating = "0"
        var screenName = ""
        
        if feedbackQuestion.questionId == 2 {
            rating =  "\(self.speed)"
            screenName = "Speed"
        }else   if feedbackQuestion.questionId == 3 {
            rating =  "\(self.accuracy)"
             screenName = "Quality"
        }else   if feedbackQuestion.questionId == 4 {
            rating =  "\(self.price)"
            screenName = "price"
        }
        
        FireBaseEventsLogger.trackReviewEvents(screenName: screenName, eventName: "EG_AddRating" , params: ["Title" : feedbackQuestion.questionTitle , "Rating" : rating , "OrderId" : self.orderTracking.orderId.stringValue])
        
        
        
//        var rating = "0"
//
//        if feedbackQuestion.questionId == 2 {
//            rating =  "\(self.speed)"
//        }else   if feedbackQuestion.questionId == 3 {
//            rating =  "\(self.accuracy)"
//        }else   if feedbackQuestion.questionId == 4 {
//            rating =  "\(self.price)"
//        }
//
//
//
//         FireBaseEventsLogger.trackReviewEvents(screenName: "price", eventName: "EG_AddRating" , params: ["Title" : feedbackQuestion.questionTitle , "Rating" : rating , "OrderId" : self.orderTracking.orderId.stringValue])
        
        
    }
    
    func answer3Handler(_ feedbackQuestion: FeedbackQuestion){
        
//        FireBaseEventsLogger.trackReviewEvents(screenName: "quality", eventName: "EG_Rating", params: ["Title" : feedbackQuestion.questionTitle , "Rating" : "\(self.price)", "OrderId" : self.orderTracking.orderId.stringValue])
        
        //Speed --- Late = 3, Accuracy --- Somewhat unsatisfied = 2, Price --- More expensive = 3
        self.pageController.nextPage()
        
        switch feedbackQuestion.questionId {
            
        case kFirstQuestionId:
            self.speed = 3
            break
            
        case kSecodQuestionId:
            self.accuracy = 2
            break
            
        case kThirdQuestionId:
            self.price = 3
            break
            
        default:
            break
        }
        
        var rating = "0"
        var screenName = ""
        
        if feedbackQuestion.questionId == 2 {
            rating =  "\(self.speed)"
            screenName = "Speed"
        }else   if feedbackQuestion.questionId == 3 {
            rating =  "\(self.accuracy)"
            screenName = "Quality"
        }else   if feedbackQuestion.questionId == 4 {
            rating =  "\(self.price)"
            screenName = "price"
        }
     
        FireBaseEventsLogger.trackReviewEvents(screenName: screenName, eventName: "EG_AddRating" , params: ["Title" : feedbackQuestion.questionTitle , "Rating" : rating , "OrderId" : self.orderTracking.orderId.stringValue])
        
    }
    
    func answer4Handler(_ feedbackQuestion: FeedbackQuestion){
        
       
        
        //Speed --- Still Waiting = 4, Accuracy --- Unsatisfied = 1
        self.pageController.nextPage()
        
        switch feedbackQuestion.questionId {
            
        case kFirstQuestionId:
            self.speed = 4
            break
            
        case kSecodQuestionId:
            self.accuracy = 1
            break
            
        default:
            break
        }
        
        var rating = "0"
        var screenName = ""
        
        if feedbackQuestion.questionId == 2 {
            rating =  "\(self.speed)"
            screenName = "Speed"
        }else   if feedbackQuestion.questionId == 3 {
            rating =  "\(self.accuracy)"
             screenName = "Quality"
        }else   if feedbackQuestion.questionId == 4 {
            rating =  "\(self.price)"
            screenName = "price"
        }
        
        FireBaseEventsLogger.trackReviewEvents(screenName: screenName, eventName: "EG_AddRating" , params: ["Title" : feedbackQuestion.questionTitle , "Rating" : rating , "OrderId" : self.orderTracking.orderId.stringValue])
        
        
        
//        var rating = "0"
//
//        if feedbackQuestion.questionId == 2 {
//            rating =  "\(self.speed)"
//        }else   if feedbackQuestion.questionId == 3 {
//            rating =  "\(self.accuracy)"
//        }else   if feedbackQuestion.questionId == 4 {
//            rating =  "\(self.price)"
//        }
//
//
//
//        FireBaseEventsLogger.trackReviewEvents(screenName: "Speed", eventName: "EG_Rating", params: ["Title" : feedbackQuestion.questionTitle , "Rating" : rating, "OrderId" : self.orderTracking.orderId.stringValue])
    }
    
    func feedbackHandler(_ commentStr: String?){
        
        print("Submit Feedback")
        // ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("deliver_feedback")
       
        
        
        if let comment = commentStr {
            self.comments = comment
            FireBaseEventsLogger.trackReviewEvents(screenName: "Send_Feeback", eventName: "EG_AddComment", params:["Comment" : self.comments , "OrderId" : self.orderTracking.orderId.stringValue ])
        }
        
        FireBaseEventsLogger.trackReviewEvents(screenName: "Send_Feeback", eventName: "EG_LeaveFeedback", params:["Comment" : self.comments , "OrderId" : self.orderTracking.orderId.stringValue ])
        
        ElGrocerUtility.sharedInstance.deliveryRating = self.delivery
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        
        let orderId = self.orderTracking.orderId.stringValue
        
        ElGrocerApi.sharedInstance.submitDeliveryFeedbackToServer(orderId, delivery: self.delivery, speed: self.speed, accuracy: self.accuracy, price: self.price, comments: self.comments, completionHandler: ({ (result) -> Void in
            
            spinner?.removeFromSuperview()
            
            switch result {
            case .success(_):
                print("Submit Feedback Success")
                let reviewPopup = ReviewPopUp.createReviewPopUp()
                reviewPopup.showPopUp()
                self.perform(#selector(self.dismissView), with: nil, afterDelay: 3.0)
                
            case .failure(let error):
                error.showErrorAlert()
            }
        }))
    }
    
    // MARK: DismissPopUp
    @objc func dismissView() {
        self.dismiss(animated: true) {
            if ElGrocerUtility.sharedInstance.deliveryRating > 3 {
                ElGrocerUtility.sharedInstance.deliveryRating = 0
                ElGrocerUtility.sharedInstance.showAppStoreReviewPopUp()
            }
        }
    }
    
    private func sendFeedbackToServer(){
        
        print("Submit Feedback")
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("deliver_feedback")
        FireBaseEventsLogger.trackReviewEvents(screenName: "Send_Feeback", eventName: "LeaveFeedback", params:[ "OrderId" : self.orderTracking.orderId.stringValue])
        
        ElGrocerUtility.sharedInstance.deliveryRating = self.delivery
        
        let orderId = self.orderTracking.orderId.stringValue
        
        ElGrocerApi.sharedInstance.submitDeliveryFeedbackToServer(orderId, delivery: self.delivery, speed: self.speed, accuracy: self.accuracy, price: self.price, comments: self.comments, completionHandler: ({ (result) -> Void in
            
            switch result {
            case .success(_):
                print("Submit Feedback Success")
                break
                
            case .failure(let error):
                print("Error While Updating Feedback to Server:%@",error.localizedMessage)
                break
            }
        }))
    }
}

extension OrderReviewViewController: PageControlDelegate {
    
    func pageControl(_ pageController: PageControlViewController, atSelected viewController: UIViewController) {
        self.pageControl.currentPage = pageController.currentPosition
    }
    
    func pageControl(_ pageController: PageControlViewController, atUnselected viewController: UIViewController) {
    }
}

extension OrderReviewViewController: PageControlDataSource {
    
    func numberOfCells(in pageController: PageControlViewController) -> Int {
        return self.dataController.count
    }
    
    func pageControl(_ pageController: PageControlViewController, cellAtRow row: Int) -> UIViewController! {
        return self.dataController[row]
    }
    
    func pageControl(_ pageController: PageControlViewController, sizeAtRow row: Int) -> CGSize {
        
        let width = pageController.view.bounds.size.width - 20
        if row == pageController.currentPosition {
            return CGSize(width: width, height: 320)
        }
        return CGSize(width: width, height: 320)
    }
}
