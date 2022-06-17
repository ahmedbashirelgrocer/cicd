//
//  ReviewQuestionViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 2/11/18.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

protocol ReviewQuestionDelegate: class {
    
    func ratingHandler(_ deliveryRating: Int)
    
    func answer1Handler(_ feedbackQuestion: FeedbackQuestion)
    func answer2Handler(_ feedbackQuestion: FeedbackQuestion)
    func answer3Handler(_ feedbackQuestion: FeedbackQuestion)
    func answer4Handler(_ feedbackQuestion: FeedbackQuestion)
    
    func feedbackHandler(_ commentStr: String?)
}

class ReviewQuestionViewController: UIViewController {
    
    //MARK: OutLets
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var answerButton4: UIButton!
    @IBOutlet weak var questionsView: UIView!
    
    @IBOutlet weak var additionalFeedbackTextView: UITextView!
    @IBOutlet weak var leaveFeedbackButton: UIButton!
    @IBOutlet weak var additionalFeedbackView: UIView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView! {
        didSet{
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                ratingView.transform = CGAffineTransform(scaleX: -1, y: 1)
                ratingView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
        }
    }
    @IBOutlet weak var ratingContainerView: UIView!
    
    var feedbackQuestion: FeedbackQuestion!
    
    weak var delegate:ReviewQuestionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.layer.cornerRadius = 5
        self.view.layer.masksToBounds = true
        
        self.setQuestionTitleLabelAppearanceAndData()
        self.setButtonAppearanceAndData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Appearance
    
    fileprivate func setUpRatingView() {
        
        self.ratingView.emptyImage = UIImage(name: "icStar")
        self.ratingView.fullImage = UIImage(name: "icStarSelected")
        
        self.ratingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.ratingView.maxRating = 5
        self.ratingView.minRating = 0
        self.ratingView.editable = true
        self.ratingView.halfRatings = false
        self.ratingView.floatRatings = false
        
        addTapGestureToRatingView()
    }
    
    // MARK: RatingView Tap (we are using gesture recognizer because touchesBegan is delayed and is to slow)
    
    func addTapGestureToRatingView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ReviewQuestionViewController.ratingViewTap(_:)))
        self.ratingView.addGestureRecognizer(tapGesture)
    }
    
    @objc func ratingViewTap(_ sender: UITapGestureRecognizer) {
        
        let touchLocation = sender.location(in: self.ratingView)
        self.ratingView.handleTouchAtLocation(touchLocation)
        
        let rating = Int(self.ratingView.rating)
        self.delegate?.ratingHandler(rating)
    }
    
    fileprivate func setRatingTitleLabelAppearanceAndData() {
        
        self.ratingLabel.font = UIFont.SFProDisplaySemiBoldFont(16.0)
        self.ratingLabel.textColor = UIColor.lightBlackColor()
        self.ratingLabel.text = feedbackQuestion.questionTitle
        self.ratingLabel.sizeToFit()
        self.ratingLabel.numberOfLines = 0
    }
    
    fileprivate func setQuestionTitleLabelAppearanceAndData() {
        
        self.questionLabel.font = UIFont.SFProDisplaySemiBoldFont(16.0)
        self.questionLabel.textColor = UIColor.lightBlackColor()
        self.questionLabel.text = feedbackQuestion.questionTitle
        self.questionLabel.sizeToFit()
        self.questionLabel.numberOfLines = 0
    }
    
    fileprivate func setButtonAppearanceAndData() {
        
        if feedbackQuestion.questionId == kRatingViewId {
            
            self.questionsView.isHidden = true
            self.additionalFeedbackView.isHidden = true
            self.ratingContainerView.isHidden = false
            
            self.setRatingTitleLabelAppearanceAndData()
            self.setUpRatingView()
            
        }else if feedbackQuestion.isAdditionalInfoView == true {

            self.questionsView.isHidden = true
            self.ratingContainerView.isHidden = true
            self.additionalFeedbackView.isHidden = false
            
            self.additionalFeedbackTextView.delegate = self
            self.additionalFeedbackTextView.layer.cornerRadius = 5
            self.additionalFeedbackTextView.layer.borderWidth = 1.0
            self.additionalFeedbackTextView.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
            self.additionalFeedbackTextView.layer.masksToBounds = true
            self.additionalFeedbackTextView.font = UIFont.SFProDisplaySemiBoldFont(15.0)
             self.additionalFeedbackTextView.backgroundColor = UIColor.white
            self.additionalFeedbackTextView.textColor = UIColor.lightTextGrayColor()
            self.additionalFeedbackTextView.text = localizedString("suggestions_placeholder_text", comment: "")
            
            self.leaveFeedbackButton.layer.cornerRadius = 3
            self.leaveFeedbackButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(15.0)
            self.leaveFeedbackButton.setTitleColor(UIColor.white, for: UIControl.State())
            self.leaveFeedbackButton.setTitle(localizedString("leave_feedback_title", comment: ""), for: UIControl.State())
            self.leaveFeedbackButton.backgroundColor = UIColor.navigationBarColor()
            
            
        }else{
            
            self.ratingContainerView.isHidden = true
            self.additionalFeedbackView.isHidden = true
            self.questionsView.isHidden = false
            
            self.answerButton1.layer.cornerRadius = 3
            self.answerButton1.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
            self.answerButton1.setTitleColor(UIColor.lightBlackColor(), for: UIControl.State())
            let answer1Title : String = String(format:"%@ \u{1F601}",feedbackQuestion.answerTitle1!)
            self.answerButton1.setTitle(answer1Title, for: UIControl.State())
            self.answerButton1.backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
            
            self.answerButton2.layer.cornerRadius = 3
            self.answerButton2.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
            self.answerButton2.setTitleColor(UIColor.lightBlackColor(), for: UIControl.State())
            let answer2Title : String = String(format:"%@ \u{1F642}",feedbackQuestion.answerTitle2!)
            self.answerButton2.setTitle(answer2Title, for: UIControl.State())
            self.answerButton2.backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
            
            self.answerButton3.layer.cornerRadius = 3
            self.answerButton3.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
            self.answerButton3.setTitleColor(UIColor.lightBlackColor(), for: UIControl.State())
            let answer3Title : String = String(format:"%@ \u{1F610}",feedbackQuestion.answerTitle3!)
            self.answerButton3.setTitle(answer3Title, for: UIControl.State())
            self.answerButton3.backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
            
            self.answerButton4.layer.cornerRadius = 3
            self.answerButton4.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
            self.answerButton4.setTitleColor(UIColor.lightBlackColor(), for: UIControl.State())
            self.answerButton4.backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
            if feedbackQuestion.answerTitle4 != nil {
                self.answerButton4.isHidden = false
                let answer4Title : String = String(format:"%@ \u{1F615}",feedbackQuestion.answerTitle4!)
                self.answerButton4.setTitle(answer4Title, for: UIControl.State())
            }else{
                self.answerButton4.isHidden = true
            }
        }
    }
    
    private func resetButtonsBackgroundColours(){
        
        self.answerButton1.setTitleColor(UIColor.lightBlackColor(), for: UIControl.State())
        self.answerButton1.backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
        
        self.answerButton2.setTitleColor(UIColor.lightBlackColor(), for: UIControl.State())
        self.answerButton2.backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
        self.answerButton3.setTitleColor(UIColor.lightBlackColor(), for: UIControl.State())
        self.answerButton3.backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
        self.answerButton4.setTitleColor(UIColor.lightBlackColor(), for: UIControl.State())
        self.answerButton4.backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
        
    }
    
    // MARK: Actions
    @IBAction func button1Handler(_ sender: Any) {
        
        self.resetButtonsBackgroundColours()
        
        self.answerButton1.setTitleColor(UIColor.meunGreenTextColor(), for: UIControl.State())
        self.answerButton1.backgroundColor = UIColor.meunCellSelectedColor()
        
        self.delegate?.answer1Handler(self.feedbackQuestion)
        
        
        
        
    }
    
    @IBAction func button2Handler(_ sender: Any) {
        
        self.resetButtonsBackgroundColours()
        
        self.answerButton2.setTitleColor(UIColor.meunGreenTextColor(), for: UIControl.State())
        self.answerButton2.backgroundColor = UIColor.meunCellSelectedColor()
        
        self.delegate?.answer2Handler(self.feedbackQuestion)
    }
    
    @IBAction func button3Handler(_ sender: Any) {
        
        self.resetButtonsBackgroundColours()
        
        self.answerButton3.setTitleColor(UIColor.meunGreenTextColor(), for: UIControl.State())
        self.answerButton3.backgroundColor = UIColor.meunCellSelectedColor()
        
        self.delegate?.answer3Handler(self.feedbackQuestion)
    }
    
    @IBAction func button4Handler(_ sender: Any) {
        
        self.resetButtonsBackgroundColours()
        
        self.answerButton4.setTitleColor(UIColor.meunGreenTextColor(), for: UIControl.State())
        self.answerButton4.backgroundColor = UIColor.meunCellSelectedColor()
        
        self.delegate?.answer4Handler(self.feedbackQuestion)
    }
    
    @IBAction func leaveFeedbackHandler(_ sender: Any) {
        
        var commentStr = ""
        if self.additionalFeedbackTextView.text != localizedString("suggestions_placeholder_text", comment: "") {
            commentStr = self.additionalFeedbackTextView.text
        }
        self.delegate?.feedbackHandler(commentStr)
    }
}

extension ReviewQuestionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == localizedString("suggestions_placeholder_text", comment: "") {
            textView.text = nil
            textView.textColor = UIColor.lightBlackColor()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = localizedString("suggestions_placeholder_text", comment: "")
            textView.textColor = UIColor.lightTextGrayColor()
        }
    }
}
