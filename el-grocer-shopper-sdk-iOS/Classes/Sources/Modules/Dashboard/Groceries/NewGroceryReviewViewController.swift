//
//  NewGroceryReviewViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 21.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

enum GroceryReviewCriteria : String {
    
    case Overall = "grocery_review_criteria_overall"
    case DeliverySpeed = "grocery_review_criteria_delivery_speed"
    case OrderAccuracy = "grocery_review_criteria_order_accuracy"
    case Quality = "grocery_review_criteria_quality"
    case Price = "grocery_review_criteria_price"
    
    static let allValues = [Overall, DeliverySpeed, OrderAccuracy, Quality, Price]
}

class NewGroceryReviewViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var groceryNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendReviewButton: UIButton!
    
    var shouldShowMenuButton = true
    
    var grocery:Grocery!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString("grocery_review_new_review_title", comment: "")
        
        //register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(NewGroceryReviewViewController.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewGroceryReviewViewController.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        addBackButton()
        
        setUpGroceryNameLabelAppearance()
        setCommentTextFieldAppearance()
        setSendReviewButtonAppearance()
        
        registerTableCell()
        self.tableViewHeightConstraint.constant = kGroceryReviewRatingCellHeight * CGFloat(GroceryReviewCriteria.allValues.count)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewGroceryReviewViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        setReviewButtonEnabled(true)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsNewGroceryReviewScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsNewGroceryReviewScreen , screenClass: String(describing: self.classForCoder))
    }
    
    // MARK: Actions
    
    override func backButtonClick() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSendReviewButton(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        
        let overallCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! GroceryReviewRatingCell
        let deliverySpeedCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! GroceryReviewRatingCell
        let orderAccuracyCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! GroceryReviewRatingCell
        let qualityCell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! GroceryReviewRatingCell
        let priceCell = self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! GroceryReviewRatingCell

        ElGrocerApi.sharedInstance.addGroceryReview(self.grocery, comment: self.commentTextView.text, overall: Int(overallCell.ratingView.rating), deliverySpeed: Int(deliverySpeedCell.ratingView.rating), orderAccuracy: Int(orderAccuracyCell.ratingView.rating), quality: Int(qualityCell.ratingView.rating), price: Int(priceCell.ratingView.rating)) { (result:Bool, reviewAlreadyAdded:Bool, responseObject:NSDictionary?) -> Void in
            
            spinner?.removeFromSuperview()
            
            if result {
                
                let dataDict = responseObject!["data"] as! NSDictionary
                GroceryReview.insertOrReplaceGroceryReviewFromDictionary(dataDict, forGrocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                
                self.navigationController?.popViewController(animated: true)
                
            } else if !reviewAlreadyAdded {
                
                ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                    description: nil,
                    positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                    negativeButton: nil, buttonClickCallback: nil).show()
                
            } else {
                
                //review already added, ask for override

                ElGrocerAlertView.createAlert(localizedString("grocery_review_already_added_alert_title", comment: ""),
                    description: localizedString("grocery_review_already_added_alert_description", comment: ""),
                    positiveButton: localizedString("grocery_review_already_added_alert_confirm_button", comment: ""),
                    negativeButton: localizedString("grocery_review_already_added_alert_cancel_button", comment: ""),
                    buttonClickCallback: { (buttonIndex:Int) -> Void in
                        
                        if buttonIndex == 0 {
                            
                            let spinner = SpinnerView.showSpinnerViewInView(self.view)
                            
                            ElGrocerApi.sharedInstance.overrideGroceryReview(self.grocery, comment: self.commentTextView.text, overall: Int(overallCell.ratingView.rating), deliverySpeed: Int(deliverySpeedCell.ratingView.rating), orderAccuracy: Int(orderAccuracyCell.ratingView.rating), quality: Int(qualityCell.ratingView.rating), price: Int(priceCell.ratingView.rating)) { (result:Bool, responseObject:NSDictionary?) -> Void in
                                
                                spinner?.removeFromSuperview()
                                
                                if result {
                                    
                                    let dataDict = responseObject!["data"] as! NSDictionary
                                    GroceryReview.insertOrReplaceGroceryReviewFromDictionary(dataDict, forGrocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                    DatabaseHelper.sharedInstance.saveDatabase()
                                    
                                    self.navigationController?.popViewController(animated: true)
                                    
                                } else {
                                    
                                    ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                                        description: nil,
                                        positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                        negativeButton: nil, buttonClickCallback: nil).show()
                                }
                                
                            }
                        }
                }).show()
                
            }
        }
    }
    
    // MARK: Appearance
    
    func setUpGroceryNameLabelAppearance() {
        
        self.groceryNameLabel.textColor = UIColor.black
        self.groceryNameLabel.font = UIFont.bookFont(14.0)
        self.groceryNameLabel.layer.cornerRadius = 4.0
        self.groceryNameLabel.layer.borderColor = UIColor.borderGrayColor().cgColor
        self.groceryNameLabel.layer.borderWidth = 1

        self.groceryNameLabel.text = self.grocery.name
    }
    
    func setCommentTextFieldAppearance() {
        
        self.commentTextField.placeholder = localizedString("grocery_review_comments_placeholder", comment: "")
        self.commentTextField.font = UIFont.bookFont(14.0)
        self.commentTextField.layer.cornerRadius = 10.0
        self.commentTextField.layer.borderColor = UIColor.borderGrayColor().cgColor
        self.commentTextField.layer.borderWidth = 1
        
        self.commentTextView.font = UIFont.bookFont(14.0)
    }
    
    func setSendReviewButtonAppearance() {
        
        self.sendReviewButton.setTitle(localizedString("grocery_review_send_review_button", comment: ""), for: UIControl.State())
        self.sendReviewButton.setTitleColor(UIColor.white, for: UIControl.State())
        self.sendReviewButton.titleLabel?.font = UIFont.bookFont(19.0)
        self.sendReviewButton.backgroundColor = UIColor.navigationBarColor()
        self.sendReviewButton.layer.cornerRadius = 6
    }
    
    // MARK: Keyboard
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.size.height)
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.view.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: UITableView
    
    func registerTableCell() {
        
        let cellNib = UINib(nibName: "GroceryReviewRatingCell", bundle: Bundle.resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: kGroceryReviewRatingCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return kGroceryReviewRatingCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return GroceryReviewCriteria.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kGroceryReviewRatingCellIdentifier, for: indexPath) as! GroceryReviewRatingCell
        let label = localizedString(GroceryReviewCriteria.allValues[(indexPath as NSIndexPath).row].rawValue, comment: "")
        
        cell.configureWithLabel(label, isLastRow: (indexPath as NSIndexPath).row == GroceryReviewCriteria.allValues.count - 1)
        
        return cell
    }

    // MARK: UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.commentTextField.placeholder = nil
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //let comment = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)

        //setReviewButtonEnabled(!comment.isEmpty)
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.commentTextField.placeholder = self.commentTextView.text.isEmpty ? localizedString("grocery_review_comments_placeholder", comment: "") : nil
    }
    
    // MARK: Validation
    
    func setReviewButtonEnabled(_ enabled:Bool) {
        
        self.sendReviewButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.sendReviewButton.alpha = enabled ? 1 : 0.3
        })
    }

}
