//
//  GroceryReviewsViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 21.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class GroceryReviewsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var scoreImage: UIImageView!
    @IBOutlet weak var ratingHeaderLabel: UILabel!
    @IBOutlet weak var ratingDescriptionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var shouldShowMenuButton = true
    
    var grocery:Grocery!
    var reviews:[GroceryReview]!
    
    var emptyView:EmptyView?
    
    // MARK: Life cycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.grocery.name
        
        addRightCrossButton()
        setUpGroceryPhoto()
        setUpGroceryReviewScoreImage()
        setUpGroceryReviewTexts()
        
        registerTableCell()
        refreshData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GroceryReviewsViewController.onReviewIconClick))
        self.scoreImage.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.getAllGroceryReviews(self.grocery, completionHandler: { (result:Bool, responseObject:NSDictionary?) -> Void in
            
            if result {
                
                let reviewsDict = (responseObject!["data"] as! NSDictionary)["reviews"] as! [NSDictionary]
                GroceryReview.insertOrReplaceGroceryReviewsFromDictionary(reviewsDict, forGrocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
            }
            
            self.refreshData()
            SpinnerView.hideSpinnerView()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsGroceryReviewsScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsGroceryReviewsScreen , screenClass: String(describing: self.classForCoder))
    }
    
    // MARK: Actions
    
    override func backButtonClick() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onReviewIconClick() {
        
        let controller = ElGrocerViewControllers.newGroceryReviewViewController()
        controller.grocery = self.grocery
        controller.shouldShowMenuButton = self.shouldShowMenuButton
        
        redirectIfLogged(controller)
    }
    
    func redirectIfLogged(_ controller:UIViewController) {
        
        if UserDefaults.isUserLoggedIn() {
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            
            (UIApplication.shared.delegate as! SDKManager).showEntryView()
            
        }
    }
    
    // MARK: Appearance (and data)
    
    func setUpGroceryPhoto() {
        
        if self.grocery.imageUrl != nil && self.grocery.imageUrl?.range(of: "http") != nil {
            
            self.photoImageView.sd_setImage(with: URL(string: self.grocery.imageUrl!), placeholderImage: UIImage(name: "category_placeholder"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.photoImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.photoImageView.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    
    func setUpGroceryReviewScoreImage() {
        
        self.scoreImage.layer.cornerRadius = 4
        
        //review scrore
        switch self.grocery.reviewScore.intValue {
            
        case 0:
            self.scoreImage.image = UIImage(name: "rating-00")
            
        case 1:
            self.scoreImage.image = UIImage(name: "rating-01")
            
        case 2:
            self.scoreImage.image = UIImage(name: "rating-02")
            
        case 3:
            self.scoreImage.image = UIImage(name: "rating-03")
            
        case 4:
            self.scoreImage.image = UIImage(name: "rating-04")
            
        case 5:
            self.scoreImage.image = UIImage(name: "rating-05")
            
        default:
            self.scoreImage.image = UIImage(name: "rating-00")
        }
    }
    
    func setUpGroceryReviewTexts() {
        
        self.ratingHeaderLabel.textColor = UIColor.white
        self.ratingHeaderLabel.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.ratingHeaderLabel.text = localizedString("grocery_review_header_label", comment: "")
        
        let ratingDescription_1 = localizedString("grocery_review_description_label_1", comment: "")
        let ratingDescription_2 = localizedString("grocery_review_description_label_2", comment: "")

        let attributedRatingDescription = NSMutableAttributedString(string: "\(ratingDescription_1)\(ratingDescription_2)")
        attributedRatingDescription.addAttribute(NSAttributedString.Key.font, value: UIFont.bookFont(13.0), range: NSMakeRange(0, ratingDescription_1.count))
        attributedRatingDescription.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplaySemiBoldFont(13.0), range: NSMakeRange(ratingDescription_1.count, ratingDescription_2.count))

        self.ratingDescriptionLabel.attributedText = attributedRatingDescription
    }
    
    // MARK: Data
    
    func refreshData() {
        
        self.reviews = self.grocery.reviews.allObjects as? [GroceryReview]
        self.reviews.sort { $0.dbID.intValue > $1.dbID.intValue }
        addEmptyView()
        self.tableView.reloadData()
    }
    
    // MARK: Empty view
    
    func addEmptyView() {
        
        self.emptyView?.removeFromSuperview()
        
        self.emptyView = EmptyView.createAndAddEmptyView(localizedString("empty_view_reviews_title", comment: ""), description: localizedString("empty_view_reviews_description", comment: ""), addToView: self.view)
        self.emptyView?.isHidden = (self.reviews.count > 0)
    }
    
    // MARK: UITableView
    
    func registerTableCell() {
        
        let cellNib = UINib(nibName: "GroceryReviewCell", bundle: Bundle.resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: kGroceryReviewCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return kGroceryReviewCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kGroceryReviewCellIdentifier, for: indexPath) as! GroceryReviewCell
        let review = self.reviews[(indexPath as NSIndexPath).row]
        
        cell.configureWithReview(review)
        
        return cell
    }

}
