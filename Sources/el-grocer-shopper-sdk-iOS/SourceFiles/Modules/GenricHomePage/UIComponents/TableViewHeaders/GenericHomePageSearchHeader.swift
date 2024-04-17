//
//  GenericHomePageSearchHeader.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 02/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

extension GenericHomePageSearchHeader {
    var profileButton: UIButton! { self.smileView.profileButton }
    var cartButton: UIButton! { self.smileView.cartButton }
    var smilesPointsView: UIView { self.smileView.smilesPointsView }
    /// Set smiles points inside smiles navigation view
    /// - Parameter points: set value -1 For not login case
    /// - Parameter points: set value >= 0  in case of connected user
    func setSmilesPoints(_ points: Int) {
        self.smileView.setSmilesPoints(points)
    }
    
    /// Resets smiles points view
    func clearSmilesPoints() {
        self.smileView.setSmilesPoints(-1)
    }
}

class GenericHomePageSearchHeader: UIView {
    
    @IBOutlet weak var btnChangeLocation: UIButton! { didSet {
        btnChangeLocation.setSubHead2BoldWhiteStyle()
        btnChangeLocation.setTitle(localizedString("changelocation_button", comment: ""), for: .normal)
    }}
    @IBOutlet weak var btnArrow: UIImageView! { didSet {
        btnArrow.image = LanguageManager.sharedInstance.getSelectedLocale() == "ar" ? UIImage(name: "LeftArrow"):UIImage(name: "RightArrow")
    }}
    @IBOutlet weak var lblToolTipMsg: UILabel! { didSet {
        lblToolTipMsg.text = localizedString("Looks like you're too far away.", comment: "")
    }}
    
    @IBOutlet weak var navigationContainer: UIView!
    @IBOutlet weak var navigationContainerTopAnchar: NSLayoutConstraint!
    @IBOutlet weak var navigationContainerBottom: NSLayoutConstraint!
    
    @IBOutlet weak var eclipseView: UIImageView! {
        didSet{
            eclipseView.image = eclipseView.image?.withCustomTintColor(color: ApplicationTheme.currentTheme.navigationBarWhiteColor)
        }
    }
    @IBOutlet var bGView: UIView!{
        didSet{
            bGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        }
    }
    @IBOutlet var topHalfBGView: UIView!{
        didSet{
            topHalfBGView.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
            topHalfBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 0, withShadow: false)
        }
    }
    @IBOutlet var searchBarBGView: UIView!{
        didSet{
            searchBarBGView.backgroundColor = ApplicationTheme.currentTheme.searchBarBGBlue50Color
            searchBarBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 22, withShadow: false)
        }
    }
    @IBOutlet var imgSearch: UIImageView!{
        didSet{
            imgSearch.image = UIImage(name: "HomeSearchHeaderBlack")
        }
    }
    @IBOutlet var txtSearch: UITextField!{
        didSet{
            txtSearch.placeholder = localizedString("search_placeholder_home", comment: "")
            txtSearch.setPlaceHolder(text: localizedString("search_placeholder_home", comment: ""), color: ApplicationTheme.currentTheme.newBlackColor)
            
          //  txtSearch.textAlignment = .natural
            
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                txtSearch.textAlignment = .right
            }else{
                txtSearch.textAlignment = .left
            }
        }
    }
    @IBOutlet weak var viewToolTip: UIView!
    @IBOutlet weak var toolTipViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var locationContainerView: UIView!
    var locationView: NavigationBarLocationView!
    let KGenericHomePageSearchHeaderHeight: CGFloat = 60
    
    @IBOutlet weak var toolTipTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!
    
    var changeLocationClickedHandler: (()->())?
    
    class func loadFromNib() -> GenericHomePageSearchHeader? {
        return self.loadFromNib(withName: "GenericHomePageSearchHeader")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpNavigationContainer()
        setIninitialAppearance()
        addLocationBar()
        setLocationHidden(false)
    }
    
//    private lazy var smileView: SmilesNavigationView = {
//        if LanguageManager.sharedInstance.getSelectedLocale() == "ar" {
//            return SmilesNavigationViewAr()
//        } else {
//            return SmilesNavigationViewEn()
//        }
//    }()
    
    private lazy var smileView: SmilesNavigationView = {
        return SmilesNavigationView()
    }()
    
    func setUpNavigationContainer() {
        navigationContainer.addSubview(smileView)
//        NSLayoutConstraint.activate([
//            smileView.centerXAnchor.constraint(equalTo: navigationContainer.centerXAnchor),
//            smileView.centerYAnchor.constraint(equalTo: navigationContainer.centerYAnchor)
//        ])
        
    }
    
    func setIninitialAppearance(){
        self.txtSearch.delegate = self
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func layoutSubviews() {
        super.layoutSubviews()

        self.locationView.translatesAutoresizingMaskIntoConstraints = false
        
        locationView.topAnchor.constraint(equalTo: locationContainerView.topAnchor, constant: 0).isActive = true
        locationView.leftAnchor.constraint(equalTo: locationContainerView.leftAnchor, constant: 10).isActive = true
        locationView.rightAnchor.constraint(equalTo: locationContainerView.rightAnchor, constant: -16).isActive = true
        locationView.bottomAnchor.constraint(equalTo: locationContainerView.bottomAnchor, constant: 0).isActive = true

//        let centerHorizontally = NSLayoutConstraint(item: self.locationView!,
//                                                    attribute: .centerY,
//                                                    relatedBy: .equal,
//                                                    toItem: self.locationContainerView,
//                                                    attribute: .centerY,
//                                                    multiplier: 1.0,
//                                                    constant: 0.0)
//        let heightConstraint =  NSLayoutConstraint(item: self.locationView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 36)
//        NSLayoutConstraint.activate([ centerHorizontally , heightConstraint])
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    fileprivate func addLocationBar() {
        self.locationView = NavigationBarLocationView.loadFromNib()
        self.locationView.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        self.locationContainerView.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        locationContainerView.addSubview(self.locationView)
    }
    func setLocationText(_ text : String = "") {
        if let location = self.locationView {
            location.lblLocation.text = text
        }
    }
    
    func setLocationHidden(_ hidden:Bool = true) {
        if let location = self.locationView {
            if hidden{
                location.visibility = .goneY
            }else{
                location.visibility = .visible
            }
            
        }
    }
    
    private var oldOffsety: CGFloat = 0
    private var newOffsety: CGFloat = 0 { didSet { oldOffsety = oldValue } }
    private var travaled: CGFloat = 0
    func viewDidScroll(_ scrollView: UIScrollView) {
        let height: CGFloat = 30
        
        newOffsety = scrollView.contentOffset.y
        
        let diff = newOffsety - oldOffsety
        let diffTravaled = travaled - diff
        
        if diff < 0 {
            travaled = min(height, diffTravaled)
        } else {
            travaled = max(0, diffTravaled)
        }
        
        scrollView.layoutIfNeeded()
        
        var headerFrame = self.frame
        headerFrame.origin.y += newOffsety - min(height - travaled, newOffsety)
        navigationContainerTopAnchar.constant = min(height - travaled, newOffsety)
        navigationContainerBottom.constant = height - min(height - travaled, newOffsety)
        
        self.frame = headerFrame
    }
    
    func navigationBarSearchTapped() {
        print("Implement in controller")
        guard let vc = UIApplication.topViewController() else {return}
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        searchController.navigationFromControllerName = FireBaseScreenName.GenericHome.rawValue
        searchController.searchFor = .isForUniversalSearch
        searchController.presentingVC = vc
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [searchController]
        
        navigationController.modalPresentationStyle = .overCurrentContext
            // self.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = false
        
        vc.present(navigationController, animated: true, completion: nil)
    }
   
    func configureLocationChangeToolTip(show: Bool) {
        self.toolTipViewHeightConstraint.constant = show ? 40 : 0
        self.viewToolTip.clipsToBounds = !show
        toolTipTopConstraint.constant = show ? 16 : 0
        searchViewTopConstraint.constant = show ? 16 : 8
        
        if show {
            self.viewToolTip.addTriangleLayerToView(x: 32, y: 0)

            btnChangeLocation.setTitle(localizedString("changelocation_button", comment: ""), for: .normal)
            btnArrow.image = LanguageManager.sharedInstance.getSelectedLocale() == "ar" ? UIImage(name: "LeftArrow"):UIImage(name: "RightArrow")
            lblToolTipMsg.text = localizedString("Looks like you're too far away.", comment: "")
            
        }
    }
    
    @IBAction func changeLocationHadnler(_ sender: Any) {
        changeLocationClickedHandler?()
    }
}
extension GenericHomePageSearchHeader: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtSearch {
          navigationBarSearchTapped()
         return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtSearch{
            navigationBarSearchTapped()
        }
    }
}

