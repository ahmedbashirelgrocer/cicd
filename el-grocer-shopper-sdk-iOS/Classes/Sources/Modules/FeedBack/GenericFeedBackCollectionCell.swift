//
//  GenericFeedBackCollectionCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class GenericFeedBackCollectionCell: UICollectionViewCell {
    
    var heightConstraint: NSLayoutConstraint?
    @IBOutlet var hidenBgView: UIView!
    @IBOutlet var backGroundView: AWView!{
        didSet{
            backGroundView.cornarRadius = 8
        }
    }
    @IBOutlet var btnSubmit: AWButton!{
        didSet{
            btnSubmit.setTitle(localizedString("btn_feedback_send_title", comment: ""), for: .normal)
            btnSubmit.setH4SemiBoldWhiteStyle()
            btnSubmit.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
        }
    }
    
    lazy var ratingView : genericStarView = {
        let ratingView = genericStarView.loadFromNib()
        return ratingView!
    }()
    lazy var writeReviewView : GenericWriteReviewView = {
        let writeReviewView = GenericWriteReviewView.loadFromNib()
        return writeReviewView!
    }()
    lazy var reviewView : GenericReviewView = {
        let reviewView = GenericReviewView.loadFromNib()
        return reviewView!
    }()
    
    var feedBackType : feedBackType = .clickAndCollectFeedBack
    var collectionView : UICollectionView?
    let topBottomPadding : CGFloat = 32.0
    
    var reviewViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reviewViewHeight = reviewView.heightAnchor.constraint(equalToConstant: 1)
        reviewViewHeight.isActive = true
    }
    
    func hideBtnSubmit(hiden : Bool){
        if hiden{
            btnSubmit.visibility = .gone
        }else{
            btnSubmit.visibility = .visible
        }
        
    }
    
    @objc func optionAPressed(sender : AWButton){
        if sender.tag == 2{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            speed.optionA = 1
            speed.optionB = 0
            speed.optionC = 0
            speed.optionD = 0
            refreshMCQView(state: speed)
        }else if sender.tag == 3{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            quality.optionA = 1
            quality.optionB = 0
            quality.optionC = 0
            quality.optionD = 0
            refreshMCQView(state: quality)
        }else if sender.tag == 4{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            price.optionA = 1
            price.optionB = 0
            price.optionC = 0
            price.optionD = 0
            refreshMCQView(state: price)
        }
        moveToNextIndex()
    }
    @objc func optionBPressed(sender : AWButton){
        if sender.tag == 2{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            speed.optionA = 0
            speed.optionB = 1
            speed.optionC = 0
            speed.optionD = 0
            refreshMCQView(state: speed)
        }else if sender.tag == 3{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            quality.optionA = 0
            quality.optionB = 1
            quality.optionC = 0
            quality.optionD = 0
            refreshMCQView(state: quality)
        }else if sender.tag == 4{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            price.optionA = 0
            price.optionB = 1
            price.optionC = 0
            price.optionD = 0
            refreshMCQView(state: price)
        }
        moveToNextIndex()
    }
    @objc func optionCPressed(sender : AWButton){
        if sender.tag == 2{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            speed.optionA = 0
            speed.optionB = 0
            speed.optionC = 1
            speed.optionD = 0
            refreshMCQView(state: speed)
        }else if sender.tag == 3{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            quality.optionA = 0
            quality.optionB = 0
            quality.optionC = 1
            quality.optionD = 0
            refreshMCQView(state: quality)
        }else if sender.tag == 4{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            price.optionA = 0
            price.optionB = 0
            price.optionC = 1
            price.optionD = 0
            refreshMCQView(state: price)
        }
        moveToNextIndex()
    }
    @objc func optionDPressed(sender : AWButton){
        if sender.tag == 2{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            speed.optionA = 0
            speed.optionB = 0
            speed.optionC = 0
            speed.optionD = 1
            
            refreshMCQView(state: speed)
        }else if sender.tag == 3{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            quality.optionA = 0
            quality.optionB = 0
            quality.optionC = 0
            quality.optionD = 1
            refreshMCQView(state: quality)
        }else if sender.tag == 4{
            sender.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            sender.setSubHead1SemiBoldWhiteStyle()
            price.optionA = 0
            price.optionB = 0
            price.optionC = 0
            price.optionD = 1
            refreshMCQView(state: price)
        }
        moveToNextIndex()
    }
    func refreshRatingView(state : selectedRating){
        
        if ratingState.speed > 0 && self.backGroundView.tag == 0{
            self.ratingView.starRatingView.rating = state.speed
        }else if ratingState.accuracy > 0 && self.backGroundView.tag == 1{
            self.ratingView.starRatingView.rating = state.accuracy
        }else if ratingState.quality > 0 && self.backGroundView.tag == 2{
            self.ratingView.starRatingView.rating = state.quality
        }else{
            self.ratingView.starRatingView.rating = 0
        }
    }
    func refreshMCQView(state : selectedOption){
        if state.optionA == 1{
            reviewView.btnOption1.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            reviewView.btnOption1.setSubHead1SemiBoldWhiteStyle()
            //default appearence
            reviewView.btnOption2.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption2.setBody3SemiBoldDarkStyle()
            reviewView.btnOption3.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption3.setBody3SemiBoldDarkStyle()
            reviewView.btnOption4.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption4.setBody3SemiBoldDarkStyle()
        }else if state.optionB == 1{
            reviewView.btnOption2.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            reviewView.btnOption2.setSubHead1SemiBoldWhiteStyle()
            //default appearence
            reviewView.btnOption1.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption1.setBody3SemiBoldDarkStyle()
            reviewView.btnOption3.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption3.setBody3SemiBoldDarkStyle()
            reviewView.btnOption4.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption4.setBody3SemiBoldDarkStyle()
        }else if state.optionC == 1{
            reviewView.btnOption3.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            reviewView.btnOption3.setSubHead1SemiBoldWhiteStyle()
            //default appearence
            reviewView.btnOption2.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption2.setBody3SemiBoldDarkStyle()
            reviewView.btnOption1.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption1.setBody3SemiBoldDarkStyle()
            reviewView.btnOption4.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption4.setBody3SemiBoldDarkStyle()
        }else if state.optionD == 1{
            reviewView.btnOption4.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            reviewView.btnOption4.setSubHead1SemiBoldWhiteStyle()
            //default appearence
            reviewView.btnOption2.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption2.setBody3SemiBoldDarkStyle()
            reviewView.btnOption3.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption3.setBody3SemiBoldDarkStyle()
            reviewView.btnOption1.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption1.setBody3SemiBoldDarkStyle()
        }else{
            //default appearence
            reviewView.btnOption1.layer.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor.cgColor
            reviewView.btnOption1.setSubHead1SemiBoldWhiteStyle()
            reviewView.btnOption2.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption2.setBody3SemiBoldDarkStyle()
            reviewView.btnOption3.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption3.setBody3SemiBoldDarkStyle()
            reviewView.btnOption4.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            reviewView.btnOption4.setBody3SemiBoldDarkStyle()
        }
    }
    func setInitialView(collectionView : UICollectionView ,feedBackType : feedBackType , index : Int){
        self.collectionView = collectionView
        self.feedBackType = feedBackType
        if feedBackType == .clickAndCollectFeedBack{
            if index < 4{
                if index == 0{
                    removeSubViews()
                    setUpRatingStarView()
                    hideBtnSubmit(hiden: true)
                    setInitialData(feedBackType: feedBackType, index: index)
                    refreshRatingView(state: ratingState)
                    self.ratingView.setNeedsLayout()
                    self.ratingView.layoutIfNeeded()
                }else if index == 1{
                    removeSubViews()
                    setUpRatingStarView()
                    hideBtnSubmit(hiden: true)
                    setInitialData( feedBackType: feedBackType, index: index)
                    refreshRatingView(state: ratingState)
                    self.ratingView.setNeedsLayout()
                    self.ratingView.layoutIfNeeded()
                }else if index == 2{
                    removeSubViews()
                    setUpRatingStarView()
                    hideBtnSubmit(hiden: true)
                    setInitialData(feedBackType: feedBackType, index: index)
                    refreshRatingView(state: ratingState)
                    self.ratingView.setNeedsLayout()
                    self.ratingView.layoutIfNeeded()
                }else if index == 3{
                    removeSubViews()
                    setUpWriteReviewView()
                    hideBtnSubmit(hiden: false)
                    setInitialData(feedBackType: feedBackType, index: index)
                    self.ratingView.setNeedsLayout()
                    self.ratingView.layoutIfNeeded()
                }
               
            }
        }else{
            if index < 5{
                if index == 0{
                    removeSubViews()
                    setUpRatingStarView()
                    hideBtnSubmit(hiden: true)
                    setInitialData(feedBackType: feedBackType, index: index)
                }else if index == 1{
                    removeSubViews()
                    setUpReviewView()
                    if reviewView.hideBtnOption4(hiden: false){
                        self.layoutIfNeeded()
                    }
                    hideBtnSubmit(hiden: true)
                    setInitialData(feedBackType: feedBackType, index: index)
                    refreshMCQView(state: speed)
                }else if index == 2{
                    removeSubViews()
                    setUpReviewView()
                    if reviewView.hideBtnOption4(hiden: false){
                        self.layoutIfNeeded()
                    }
                    hideBtnSubmit(hiden: true)
                    setInitialData(feedBackType: feedBackType, index: index)
                    refreshMCQView(state: quality)
                }else if index == 3{
                    removeSubViews()
                    setUpReviewView()
                    if reviewView.hideBtnOption4(hiden: true){
                        self.layoutIfNeeded()
                    }
                    hideBtnSubmit(hiden: true)
                    setInitialData(feedBackType: feedBackType, index: index)
                    refreshMCQView(state: price)
                }else if index == 4{
                    removeSubViews()
                    setUpWriteReviewView()
                    hideBtnSubmit(hiden: false)
                    setInitialData(feedBackType: feedBackType, index: index)
                }
            }
        }
    }
    
    fileprivate func setInitialData(feedBackType : feedBackType , index : Int){
        if feedBackType == .clickAndCollectFeedBack{
            if index < 4{
                if index == 0{
                    self.ratingView.lblHeading.text = localizedString("lbl_click&Collect_feedback_Q1", comment: "")
                }else if index == 1{
                    self.ratingView.lblHeading.text = localizedString("lbl_click&Collect_feedback_Q2", comment: "")
                }else if index == 2{
                    self.ratingView.lblHeading.text = localizedString("lbl_click&Collect_feedback_Q3", comment: "")
                    self.ratingView.lblHeading.sizeToFit()
                }else if index == 3{
                    self.writeReviewView.lblHeading.text = localizedString("lbl_click&Collect_feedback_Q4", comment: "")
                    self.writeReviewView.lbl_help_us_be_better.text = localizedString("lbl_delivery_feedback_textView_heading", comment: "").uppercased()
                    let placeHolder = NSAttributedString(string: localizedString("lbl_delivery_feedback_textView_placeHolder", comment: "") , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor() , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14)])
                    self.writeReviewView.growingTextView.attributedPlaceholder = placeHolder
                }
            }
        }else{
            if index < 5{
                if index == 0{
                    self.ratingView.lblHeading.text = localizedString("lbl_delivery_feedback_Q1", comment: "")
                }else if index == 1{
                    self.reviewView.lblHeading.text = localizedString("lbl_delivery_feedback_Q2", comment: "")
                    
                    self.reviewView.btnOption1.setTitle(localizedString("lbl_delivery_feedback_Q2_A1", comment: ""), for: .normal)
                    self.reviewView.btnOption1.tag = 2
                    self.reviewView.btnOption1.addTarget(self, action: #selector(optionAPressed(sender:)), for: .touchDown)
                    self.reviewView.btnOption2.setTitle(localizedString("lbl_delivery_feedback_Q2_A2", comment: ""), for: .normal)
                    self.reviewView.btnOption2.tag = 2
                    self.reviewView.btnOption2.addTarget(self, action: #selector(optionBPressed(sender:)), for: .touchDown)
                    self.reviewView.btnOption3.setTitle(localizedString("lbl_delivery_feedback_Q2_A3", comment: ""), for: .normal)
                    self.reviewView.btnOption3.tag = 2
                    self.reviewView.btnOption3.addTarget(self, action: #selector(optionCPressed(sender:)), for: .touchDown)
                    self.reviewView.btnOption4.setTitle(localizedString("lbl_delivery_feedback_Q2_A4", comment: ""), for: .normal)
                    self.reviewView.btnOption4.tag = 2
                    self.reviewView.btnOption4.addTarget(self, action: #selector(optionDPressed(sender:)), for: .touchDown)
                }else if index == 2{
                    self.reviewView.lblHeading.text = localizedString("lbl_delivery_feedback_Q3", comment: "")
                    
                    self.reviewView.btnOption1.setTitle(localizedString("lbl_delivery_feedback_Q3_A1", comment: ""), for: .normal)
                    self.reviewView.btnOption1.tag = 3
                    self.reviewView.btnOption1.addTarget(self, action: #selector(optionAPressed(sender:)), for: .touchDown)
                    self.reviewView.btnOption2.setTitle(localizedString("lbl_delivery_feedback_Q3_A2", comment: ""), for: .normal)
                    self.reviewView.btnOption2.tag = 3
                    self.reviewView.btnOption2.addTarget(self, action: #selector(optionBPressed(sender:)), for: .touchDown)
                    self.reviewView.btnOption3.setTitle(localizedString("lbl_delivery_feedback_Q3_A3", comment: ""), for: .normal)
                    self.reviewView.btnOption3.tag = 3
                    self.reviewView.btnOption3.addTarget(self, action: #selector(optionCPressed(sender:)), for: .touchDown)
                    self.reviewView.btnOption4.setTitle(localizedString("lbl_delivery_feedback_Q3_A4", comment: ""), for: .normal)
                    self.reviewView.btnOption4.tag = 3
                    self.reviewView.btnOption4.addTarget(self, action: #selector(optionDPressed(sender:)), for: .touchDown)
                }else if index == 3{
                    self.reviewView.lblHeading.text = localizedString("lbl_delivery_feedback_Q4", comment: "")
                    
                    self.reviewView.btnOption1.setTitle(localizedString("lbl_delivery_feedback_Q4_A1", comment: ""), for: .normal)
                    self.reviewView.btnOption1.tag = 4
                    self.reviewView.btnOption1.addTarget(self, action: #selector(optionAPressed(sender:)), for: .touchDown)
                    self.reviewView.btnOption2.setTitle(localizedString("lbl_delivery_feedback_Q4_A2", comment: ""), for: .normal)
                    self.reviewView.btnOption2.tag = 4
                    self.reviewView.btnOption2.addTarget(self, action: #selector(optionBPressed(sender:)), for: .touchDown)
                    self.reviewView.btnOption3.setTitle(localizedString("lbl_delivery_feedback_Q4_A3", comment: ""), for: .normal)
                    self.reviewView.btnOption3.tag = 4
                    self.reviewView.btnOption3.addTarget(self, action: #selector(optionCPressed(sender:)), for: .touchDown)
                }else if index == 4{
                    self.writeReviewView.lblHeading.text = localizedString("lbl_delivery_feedback_Q5", comment: "")
                    self.writeReviewView.lbl_help_us_be_better.text = localizedString("lbl_delivery_feedback_textView_heading", comment: "").uppercased()
                    let placeHolder = NSAttributedString(string: localizedString("lbl_delivery_feedback_textView_placeHolder", comment: "") , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor() , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14)])
                    
                    self.writeReviewView.growingTextView.attributedPlaceholder = placeHolder
                }
            }
        }
    }
    
    func removeSubViews(){
        backGroundView.subviews.forEach({ $0.removeFromSuperview() })
    }
    func getHeight(Type : feedBackType , index : Int) -> CGFloat {
        if Type == .clickAndCollectFeedBack{
            if index == 0{
                return 139
            }else if index == 1 || index == 2{
                return 164
            }else{
                return 213
            }
        }else{
            if index == 0{
                return 139
            }else if index == 1{
                return 289
            }else if index == 2{
                return 314
            }else if index == 3{
                return 258
            }else{
                return 213
            }

        }
    }
    
    func moveToNextIndex(){
        self.collectionView?.scrollToNextItem()
    }
    
    func setUpRatingStarView(){
        
        let height = getHeight(Type: feedBackType, index: self.backGroundView.tag)
        self.setup(height)
        
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        self.backGroundView.addSubview(ratingView)
        self.backGroundView.bringSubviewToFront(ratingView)
        
        ratingView.setRatingViewDelegate(delegate: self)
        ratingView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor).isActive = true
        ratingView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor).isActive = true
        ratingView.topAnchor.constraint(equalTo: backGroundView.topAnchor).isActive = true
        ratingView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor , constant: 0).isActive = true
        self.reviewViewHeight.constant = height
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
//            ratingView.transform = CGAffineTransform(scaleX: -1, y: 1)
//            ratingView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            
            //ratingView.lblHeading.transform = CGAffineTransform(scaleX: -1, y: 1)
            ratingView.starRatingView.transform = CGAffineTransform(scaleX: -1, y: 1)
            //ratingView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
        //ratingView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setup(_ height : CGFloat) {
        if heightConstraint == nil {
            heightConstraint = ratingView.heightAnchor.constraint(equalToConstant: height)
        }
        
    }
    
    func show(_ height : CGFloat) {
        if heightConstraint != nil {
            heightConstraint = ratingView.heightAnchor.constraint(equalToConstant: height)
        }
    }
    
    func setUpReviewView(){
        let height = getHeight(Type: feedBackType, index: self.backGroundView.tag)
        
        reviewView.translatesAutoresizingMaskIntoConstraints = false
        self.backGroundView.addSubview(reviewView)
        self.backGroundView.bringSubviewToFront(reviewView)
        
        reviewView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor).isActive = true
        reviewView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor).isActive = true
        reviewView.topAnchor.constraint(equalTo: backGroundView.topAnchor).isActive = true
        reviewView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor , constant: 0).isActive = true
        reviewViewHeight.constant = height
    }
    func setUpWriteReviewView(){
        let height = getHeight(Type: feedBackType, index: self.backGroundView.tag)
        
        writeReviewView.translatesAutoresizingMaskIntoConstraints = false
        self.backGroundView.addSubview(writeReviewView)
        self.backGroundView.bringSubviewToFront(writeReviewView)
        
        writeReviewView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor).isActive = true
        writeReviewView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor).isActive = true
        writeReviewView.topAnchor.constraint(equalTo: backGroundView.topAnchor).isActive = true
        writeReviewView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor , constant: 0).isActive = true
        reviewViewHeight.constant = height
    }
    
}
extension GenericFeedBackCollectionCell: FloatRatingViewDelegate {
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
       elDebugPrint(String(format: "%.2f", ratingView.rating))
        self.collectionView?.isScrollEnabled = true
        
        if self.tag == 1{
            if backGroundView.tag == 0{
                ratingState.speed = ratingView.rating
                moveToNextIndex()
            }else if backGroundView.tag == 1{
                ratingState.accuracy = ratingView.rating
                moveToNextIndex()
            }else if backGroundView.tag == 2{
                ratingState.quality = ratingView.rating
                moveToNextIndex()
            }
        }else{
            if self.backGroundView.tag == 0{
                delivery = ratingView.rating
                moveToNextIndex()
            }
        }
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Float) {
        self.collectionView?.isScrollEnabled = false
    }
}
